;;; org-rich-copy.el --- Copy Org links and images to other applications -*- lexical-binding: t; -*-

(require 'org)
(require 'org-element)
(require 'ox)
(require 'cl-lib)
(require 'json)
(require 'xml)
(require 'org-paste-common
         (expand-file-name "org-paste-common.el"
                           (file-name-directory
                            (or load-file-name
                                (bound-and-true-p byte-compile-current-file)
                                buffer-file-name))))

(defconst my-org-rich-copy--native-source
  (expand-file-name "org-copy-macos.m"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defvar my-org-rich-copy--last nil
  "The last published rich copy, used to preserve native Emacs kill entries.")

(defun my-org-rich-copy--helper ()
  "Return the cached native clipboard helper, compiling it if necessary."
  (let* ((hash (with-temp-buffer
                 (insert-file-contents-literally my-org-rich-copy--native-source)
                 (secure-hash 'sha256 (current-buffer))))
         (directory (expand-file-name "~/.cache/emacs/org-clipboard/"))
         (binary (expand-file-name (concat "copy-" hash) directory)))
    (unless (file-executable-p binary)
      (make-directory directory t)
      (let ((temporary (make-temp-file (expand-file-name "build-" directory))))
        (unwind-protect
            (progn
              (unless (eq 0 (call-process "/usr/bin/clang" nil nil nil
                                          "-fobjc-arc" "-O2" "-framework" "AppKit"
                                          my-org-rich-copy--native-source "-o" temporary))
                (error "Could not compile the macOS clipboard helper"))
              (set-file-modes temporary #o700)
              (rename-file temporary binary t))
          (when (file-exists-p temporary) (delete-file temporary)))))
    binary))

(defun my-org-rich-copy--escape (text)
  "Escape TEXT as literal HTML, preserving its line breaks."
  (replace-regexp-in-string "\n" "<br>\n" (xml-escape-string text) t t))

(defun my-org-rich-copy--image (link directory)
  "Read a complete local image LINK relative to DIRECTORY, or return nil."
  (when (and (equal (org-element-property :type link) "file")
             (not (org-element-contents-begin link)))
    (let* ((path (org-link-unescape (org-element-property :path link)))
           (file (expand-file-name path directory))
           (extension (downcase (or (file-name-extension file) "")))
           (mime (cdr (assoc extension '(("png" . "image/png") ("jpg" . "image/jpeg")
                                        ("jpeg" . "image/jpeg") ("gif" . "image/gif")
                                        ("tif" . "image/tiff") ("tiff" . "image/tiff")
                                        ("webp" . "image/webp") ("svg" . "image/svg+xml"))))))
      (when (and mime (not (file-remote-p file)) (file-regular-p file) (file-readable-p file))
        (list :path file :uri
              (concat "data:" mime ";base64,"
                      (with-temp-buffer
                        (set-buffer-multibyte nil)
                        (insert-file-contents-literally file)
                        (base64-encode-string (buffer-string) t))))))))

(defun my-org-rich-copy--render (source)
  "Render SOURCE as portable text, hyperlinks, and embedded local images.
Keep Org text in the kill ring.  Only ordinary web/mail links and readable
local image files are exported; never execute directives or fetch URLs."
  (let ((directory (if buffer-file-name (file-name-directory buffer-file-name) default-directory)))
    (with-temp-buffer
      (let ((org-inhibit-startup t) (org-mode-hook nil)) (org-mode))
      (insert (substring-no-properties (my-org-paste-clean-image-metadata source)))
      (let ((cursor (point-min)) (offset 0) html plain links images found)
        (org-element-map (org-element-parse-buffer) 'link
          (lambda (link)
            (let ((image (my-org-rich-copy--image link directory))
                  (web (and (member (org-element-property :type link) '("http" "https" "mailto" "ftp"))
                            (not (and (eq (org-element-property :format link) 'plain)
                                      (eq (char-before (org-element-begin link)) ?\[))))))
              (when (or image web)
                (let* ((begin (org-element-begin link))
                       (end (- (org-element-end link) (org-element-post-blank link)))
                       (url (org-element-property :raw-link link))
                       (label (cond (image "\ufffc")
                                    ((org-element-contents-begin link)
                                     (buffer-substring-no-properties
                                      (org-element-contents-begin link) (org-element-contents-end link)))
                                    (t url)))
                       (paragraph (and image (org-element-lineage link 'paragraph)))
                       (prefix (buffer-substring-no-properties cursor begin))
                       (width (and paragraph (org-export-read-attribute :attr_org paragraph :width))))
                  (when (and paragraph (org-element-property :attr_org paragraph))
                    ;; Remove only this image's attributes, not arbitrary directives.
                    (let ((attribute-start (max cursor (org-element-begin paragraph)))
                          (case-fold-search t))
                      (setq prefix
                            (concat (buffer-substring-no-properties cursor attribute-start)
                                    (replace-regexp-in-string
                                     "^[ \t]*#\\+ATTR_ORG:.*\n" ""
                                     (buffer-substring-no-properties attribute-start begin))))))
                  (setq offset (+ offset (/ (length (encode-coding-string prefix 'utf-16le t)) 2)))
                  (push (concat prefix label) plain)
                  (push (concat (my-org-rich-copy--escape prefix)
                                (if image
                                    (format "<img alt=\"Image\" src=\"%s\"%s>" (plist-get image :uri)
                                            (if (and width (string-match-p "\\`[0-9]+\\'" width))
                                                (format " width=\"%s\"" width) ""))
                                  (concat "<a href=\"" (xml-escape-string url) "\">"
                                          (my-org-rich-copy--escape label) "</a>"))) html)
                  (let ((length (/ (length (encode-coding-string label 'utf-16le t)) 2)))
                    (if image
                        (push `((start . ,offset) (path . ,(plist-get image :path))
                                (width . ,(if width (string-to-number width) 0))) images)
                      (push `((start . ,offset) (length . ,length) (url . ,url)) links))
                    (setq offset (+ offset length)))
                  (setq cursor end found t))))))
        (when found
          (let* ((tail (buffer-substring-no-properties cursor (point-max)))
                 (plain (concat (apply #'concat (nreverse plain)) tail))
                 (images (nreverse images))
                 (token (secure-hash 'sha256 (format "%s:%s:%s" (emacs-pid) (float-time) (random)))))
            (list :html (concat "<!DOCTYPE html><html><head><meta charset=\"utf-8\"></head><body>"
                                "<!--emacs-org-copy:" token "-->"
                                "<div style=\"font:12pt Helvetica;white-space:pre-wrap\">"
                                (apply #'concat (nreverse html)) (my-org-rich-copy--escape tail)
                                "</div></body></html>")
                  :plain plain :links (vconcat (nreverse links)) :images (vconcat images)
                  :image-only (and (= (length images) 1)
                                   (string-blank-p (replace-regexp-in-string "\ufffc" "" plain)) t))))))))

(defun my-org-rich-copy--write (data source)
  "Publish DATA if the clipboard still contains the original SOURCE."
  (let ((helper (my-org-rich-copy--helper)))
    (with-temp-buffer
      (insert (json-encode `((html . ,(plist-get data :html))
                             (plain . ,(plist-get data :plain))
                             (links . ,(plist-get data :links))
                             (images . ,(plist-get data :images))
                             (imageOnly . ,(if (plist-get data :image-only) t :json-false))
                             (expected . ,(substring-no-properties source)))))
      (let ((coding-system-for-write 'utf-8-unix)
            (coding-system-for-read 'utf-8-unix))
        (eq 0 (call-process-region (point-min) (point-max) helper nil nil nil))))))

(defun my-org-rich-copy--ours-p ()
  "Whether the clipboard is still our exact rich copy.
The unguessable HTML comment distinguishes an internal copy from later
external copies with the same visible text.  Do not import our own HTML
back through Pandoc and lose Org whitespace or Evil's yank handler."
  (and my-org-rich-copy--last select-enable-clipboard (display-graphic-p)
       (ignore-errors
         (and (memq 'text/html (append (gui-get-selection 'CLIPBOARD 'TARGETS) nil))
              (equal (gui-get-selection 'CLIPBOARD 'text/html)
                     (plist-get my-org-rich-copy--last :html))))))

(defun my-org-rich-copy--selection-value (original &rest args)
  "Keep using the original kill-ring object for our own clipboard copy."
  (unless (my-org-rich-copy--ours-p) (apply original args)))

(defun my-org-rich-copy--select-text (original text)
  "Publish Org links and images after ORIGINAL has copied TEXT normally."
  (prog1 (funcall original text)
    (when (and (eq system-type 'darwin) select-enable-clipboard
               (display-graphic-p) (derived-mode-p 'org-mode)
               (not (org-in-src-block-p t))
               (not (org-in-block-p '("example" "export"))))
      (condition-case err
          (when-let* ((data (my-org-rich-copy--render text)))
            (when (my-org-rich-copy--write data text)
              (setq my-org-rich-copy--last data)))
        (error (message "Rich copy: %s; kept plain text" (error-message-string err)))))))

(define-minor-mode my-org-rich-copy-mode
  "Copy Org links and images in native formats for other macOS applications.
Emacs retains the exact original kill-ring text and its yank properties."
  :global t
  :group 'org
  (if my-org-rich-copy-mode
      (progn
        (advice-add 'gui-select-text :around #'my-org-rich-copy--select-text)
        (advice-add 'gui-selection-value :around #'my-org-rich-copy--selection-value)
        (add-hook 'my-org-paste-internal-clipboard-functions #'my-org-rich-copy--ours-p))
    (advice-remove 'gui-select-text #'my-org-rich-copy--select-text)
    (advice-remove 'gui-selection-value #'my-org-rich-copy--selection-value)
    (remove-hook 'my-org-paste-internal-clipboard-functions #'my-org-rich-copy--ours-p)))

(provide 'org-rich-copy)
;;; org-rich-copy.el ends here
