;;; org-html-paste.el --- Paste HTML and RTF links into Org -*- lexical-binding: t; -*-

;; Command-V (org-yank), C-y, and Evil p/P all read through current-kill.
;; Keep rich text alongside the original kill-ring entry and convert only the
;; returned value.  This preserves paste placement, counts, undo, and plain
;; text in other modes without maintaining separate key bindings.

(require 'org)
(require 'cl-lib)
(require 'subr-x)
(require 'dom)
(declare-function my-org-image-paste--save "org-image-paste")
(require 'org-paste-common
         (expand-file-name "org-paste-common.el"
                           (file-name-directory
                            (or load-file-name
                                (bound-and-true-p byte-compile-current-file)
                                buffer-file-name))))

(defgroup my-org-html-paste nil
  "Paste rich clipboard content into Org."
  :group 'org)

(defcustom my-org-html-paste-pandoc
  (or (executable-find "pandoc")
      (cl-find-if #'file-executable-p
                  '("/opt/homebrew/bin/pandoc" "/usr/local/bin/pandoc"))
      "pandoc")
  "Pandoc executable used to convert clipboard HTML and RTF."
  :type 'string)

(defvar my-org-html-paste--entries (make-hash-table :test 'eq :weakness 'key)
  "Map original kill-ring strings to ((FORMAT . DATA) . CONVERTED-ORG).
Use object identity so an internal copy with the same text cannot inherit
an unrelated browser link.  Entries expire when their strings are collected.")

(defconst my-org-html-paste--filter-file
  (expand-file-name "org-html-paste.lua"
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Filter that removes inline styling while preserving links.")

(defun my-org-html-paste--remember (text)
  "Remember the current clipboard rich text if it corresponds to TEXT."
  (when (and (stringp text) (not (string-empty-p text)))
    (let* ((types (my-org-paste-clipboard-types))
           (source (my-org-paste-clipboard-rich-text types)))
      (when (and source (equal text (my-org-paste-clipboard-text types)))
        (unless (equal source (car (gethash text my-org-html-paste--entries)))
          (puthash text (cons source nil) my-org-html-paste--entries))))))

(defun my-org-html-paste--convert (data text &optional format)
  "Convert DATA to unstyled Org, using TEXT to preserve a trailing newline.
FORMAT is `html' (the default) or `rtf'."
  (let ((note-directory (if buffer-file-name (file-name-directory buffer-file-name) default-directory)))
   (with-temp-buffer
    (insert data)
    (let ((coding-system-for-read 'utf-8-unix)
          (coding-system-for-write 'utf-8-unix)
          (default-directory temporary-file-directory))
      (when (eq format 'rtf)
        ;; Use macOS's native RTF reader: Pandoc's RTF reader can split
        ;; Unicode link labels and lose spaces around RTF formatting runs.
        ;; RTF declares its own encoding, so preserve literal 8-bit bytes.
        (let ((coding-system-for-write 'no-conversion))
          (unless (eq 0 (call-process-region
                         (point-min) (point-max) "/usr/bin/textutil"
                         t (list t nil) nil
                         "-format" "rtf" "-convert" "html" "-encoding" "UTF-8"
                         "-stdin" "-stdout" "-nostore" "-strip"))
            (error "Could not decode clipboard RTF"))))
      (when (and (bound-and-true-p my-org-image-paste-mode)
                 (save-excursion (goto-char (point-min)) (search-forward "data:image/" nil t)))
        (my-org-html-paste--embedded-images note-directory))
      (unless (eq 0 (call-process-region
                     (point-min) (point-max) my-org-html-paste-pandoc
                     t (list t nil) nil
                     "--from=html-native_divs-native_spans" "--to=org"
                     "--lua-filter" my-org-html-paste--filter-file
                     "--wrap=none"))
        (error "Pandoc could not convert clipboard rich text")))
    (let ((result (my-org-paste-clean-image-metadata
                   (replace-regexp-in-string "\u00a0" " " (buffer-string)))))
      (when (string-empty-p (string-trim result))
        (error "Rich text conversion produced no text"))
      (if (string-suffix-p "\n" text)
          result
        (string-remove-suffix "\n" result))))))

(defun my-org-html-paste--embedded-images (directory)
  "Save embedded HTML image data beside the note in DIRECTORY.
Only read data carried by the clipboard; do not fetch remote image URLs."
  (let ((dom (libxml-parse-html-region (point-min) (point-max)))
        (default-directory directory))
    (dolist (comment (dom-by-tag dom 'comment)) (dom-remove-node dom comment))
    (dolist (image (dom-by-tag dom 'img))
      (let ((source (dom-attr image 'src)))
        (when (and source (string-match
                           "\\`data:image/\\(png\\|jpeg\\|gif\\|tiff\\|webp\\);base64,\\(.*\\)\\'" source))
          (let* ((extension (if (equal (match-string 1 source) "jpeg") ".jpg"
                              (concat "." (match-string 1 source))))
                 (bytes (base64-decode-string (match-string 2 source)))
                 (link (my-org-image-paste--save (cons extension bytes))))
            (dom-set-attribute image 'src (substring link 2 -2))))))
    (erase-buffer)
    (dom-print dom)))

(defun my-org-html-paste--current-kill (original n &optional do-not-move)
  "Read a kill using ORIGINAL, N and DO-NOT-MOVE, converting rich text in Org."
  (let ((text (funcall original n do-not-move)))
    ;; Capture even outside Org, so pasting from history can retain links
    ;; after the system clipboard changes.  Never associate older history
    ;; entries with rich text that happens to be on the clipboard now.
    (when (zerop n)
      (my-org-html-paste--remember text))
    (let ((entry (gethash text my-org-html-paste--entries)))
      (if (and entry (derived-mode-p 'org-mode)
               (not (org-in-src-block-p t))
               (not (org-in-block-p '("example" "export"))))
          (condition-case err
              (or (and (not (string-match-p "data:image/" (cdar entry))) (cdr entry))
                  (setcdr entry (my-org-html-paste--convert
                                 (cdar entry) text (caar entry))))
            (error
             (message "Rich text paste: %s; using plain text" (error-message-string err))
             text))
        text))))

(define-minor-mode my-org-html-paste-mode
  "Preserve HTML and RTF links with the existing Org and Evil paste commands.
Requires Pandoc.  Plain clipboard text, named Evil registers, other modes,
and Org source/example/export blocks retain their usual behavior.
RTF also requires macOS's built-in textutil program."
  :global t
  :group 'my-org-html-paste
  (if my-org-html-paste-mode
      (advice-add 'current-kill :around #'my-org-html-paste--current-kill)
    (advice-remove 'current-kill #'my-org-html-paste--current-kill)
    (clrhash my-org-html-paste--entries)))

;; Drop entries misclassified by the previous NS clipboard implementation,
;; migrate old HTML-only entries, and reconvert after reloading this module.
(maphash (lambda (text entry)
           (cond
            ((equal text (car entry))
             (remhash text my-org-html-paste--entries))
            (t
             (when (stringp (car entry))
               (setcar entry (cons 'html (car entry))))
             (setcdr entry nil))))
         my-org-html-paste--entries)

(provide 'org-html-paste)
;;; org-html-paste.el ends here
