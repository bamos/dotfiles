;;; org-image-paste.el --- Paste clipboard images into Org -*- lexical-binding: t; -*-

;; Like org-html-paste.el, use the shared kill-ring reader so Command-V,
;; C-y, and Evil p/P keep their normal placement, counts, and undo behavior.
(require 'org)
(require 'cl-lib)
(require 'dom)
(require 'subr-x)
(require 'org-paste-common
         (expand-file-name "org-paste-common.el"
                           (file-name-directory
                            (or load-file-name
                                (bound-and-true-p byte-compile-current-file)
                                buffer-file-name))))

(defgroup my-org-image-paste nil
  "Save clipboard images and display them inline in Org."
  :group 'org)

(defcustom my-org-image-paste-directory "images"
  "Directory for pasted images, relative to the current Org file.
An absolute directory puts all images in that shared directory instead."
  :type 'directory)

(defvar my-org-image-paste--last-image nil
  "Last saved image as (DIGEST DIRECTORY FILE), avoiding duplicate files.")

(defun my-org-image-paste--clipboard-image ()
  "Return (EXTENSION . BYTES) for an image on the graphical clipboard.
Prefer rich text over an accompanying preview image, but allow HTML that
only contains an image (as supplied by a browser's Copy Image command)."
  (when-let* ((types (my-org-paste-clipboard-types)))
    (let* ((source (my-org-paste-clipboard-rich-text types))
           (html (and (eq (car source) 'html) (cdr source)))
           (rtf-text (and (eq (car source) 'rtf)
                          (my-org-paste-clipboard-text types)))
           (html-text
            (when (and (stringp html) (not (string-empty-p html)))
              (condition-case nil
                  (with-temp-buffer
                    (insert html)
                    (let* ((dom (libxml-parse-html-region (point-min) (point-max)))
                           (body (or (car (dom-by-tag dom 'body)) dom)))
                      (string-trim (dom-texts body))))
                ;; Preserve the established HTML paste behavior on parse errors.
                (error "HTML text")))))
      (unless (or (and html-text (not (string-empty-p html-text)))
                  ;; A standalone attachment can contribute only an object
                  ;; replacement character, which is not meaningful text.
                  (and rtf-text
                       (not (string-empty-p
                             (string-trim
                              (replace-regexp-in-string "\ufffc" "" rtf-text))))))
        (cl-loop for (type . extension) in
                 '((image/png . ".png") (image/jpeg . ".jpg")
                   (image/tiff . ".tiff") (image/gif . ".gif")
                   (image/webp . ".webp"))
                 for data = (my-org-paste-clipboard-data type types)
                 when (and (stringp data) (> (length data) 0))
                 return (cons extension data))))))

(defun my-org-image-paste--same-file-p (file digest size)
  "Whether FILE still contains exactly SIZE bytes with SHA256 DIGEST."
  (and file
       (ignore-errors
         (and (file-regular-p file)
              (= size (file-attribute-size (file-attributes file)))
              (with-temp-buffer
                (set-buffer-multibyte nil)
                (insert-file-contents-literally file)
                (equal digest (secure-hash 'sha256 (current-buffer))))))))

(defun my-org-image-paste--save (image)
  "Save IMAGE and return an Org file link relative to the current note."
  (let* ((note-directory (if buffer-file-name
                             (file-name-directory buffer-file-name)
                           default-directory))
         (directory (file-name-as-directory
                     (expand-file-name my-org-image-paste-directory note-directory)))
         (digest (secure-hash 'sha256 (cdr image)))
         (size (string-bytes (cdr image)))
         (previous my-org-image-paste--last-image)
         (file (and (equal digest (nth 0 previous))
                    (equal directory (nth 1 previous))
                    (my-org-image-paste--same-file-p (nth 2 previous) digest size)
                    (nth 2 previous))))
    (unless file
      ;; Size filters avoid reading unrelated images.  Verify bytes so this
      ;; also works after a restart, and never reuse an edited cached file.
      (setq file
            (and (file-directory-p directory)
                 (cl-find-if (lambda (candidate)
                               (my-org-image-paste--same-file-p candidate digest size))
                             (directory-files directory t (image-file-name-regexp))))))
    (unless file
      (make-directory directory t)
      (setq file (make-temp-file
                  (expand-file-name (format-time-string "clipboard-%Y%m%d-%H%M%S-")
                                    directory)
                  nil (car image)))
      (condition-case err
          (let ((coding-system-for-write 'no-conversion))
            (with-temp-buffer
              (set-buffer-multibyte nil)
              (insert (cdr image))
              (write-region (point-min) (point-max) file nil 'silent)))
        (error (delete-file file) (signal (car err) (cdr err)))))
    (setq my-org-image-paste--last-image (list digest directory file))
    (org-link-make-string (concat "file:" (file-relative-name file note-directory)))))

(defun my-org-image-paste--display ()
  "Refresh image previews once the paste command has finished."
  (remove-hook 'post-command-hook #'my-org-image-paste--display t)
  (when (derived-mode-p 'org-mode)
    (org-display-inline-images nil t)))

(defun my-org-image-paste--insert-args (args)
  "Repair escaped image metadata in pasted text outside literal blocks."
  (if (and (derived-mode-p 'org-mode) (stringp (car args))
           (not (org-in-src-block-p t))
           (not (org-in-block-p '("example" "export"))))
      (cons (my-org-paste-clean-image-metadata (car args)) (cdr args))
    args))

(defun my-org-image-paste--after-insert (text)
  "Refresh previews after pasting TEXT containing an existing image link.
Both ordinary yank and Evil paste use `insert-for-yank', including named
registers and history.  Wait until command completion so counts, placement,
and Org's own paste processing finish before creating the image overlays."
  (when (and (derived-mode-p 'org-mode) (stringp text)
             (not (org-in-src-block-p t))
             (not (org-in-block-p '("example" "export"))))
    (save-match-data
      (let ((start 0) found)
        (while (and (not found) (string-match org-link-bracket-re text start))
          (let ((target (match-string-no-properties 1 text)))
            (setq start (match-end 0)
                  found (and (string-match-p "\\`\\(?:file\\|attachment\\):" target)
                             (string-match-p (image-file-name-regexp)
                                             (org-link-unescape target))))))
        (when found
          (add-hook 'post-command-hook #'my-org-image-paste--display nil t))))))

(defun my-org-image-paste--current-kill (original n &optional do-not-move)
  "Read a kill with ORIGINAL, N and DO-NOT-MOVE, importing clipboard images."
  (let ((image (and (zerop n) (derived-mode-p 'org-mode)
                    (not (org-in-src-block-p t))
                    (not (org-in-block-p '("example" "export")))
                    (my-org-image-paste--clipboard-image))))
    (if (not image)
        (funcall original n do-not-move)
      (let* ((link (my-org-image-paste--save image))
             ;; Feed the saved link through the same import mechanism as text.
             ;; Do not replace the system clipboard with a file path.
             (interprogram-paste-function
              (lambda () (unless (equal link (car kill-ring)) link))))
        (funcall original n do-not-move)))))

(define-minor-mode my-org-image-paste-mode
  "Paste clipboard images using the existing Org and Evil paste commands."
  :global t
  :group 'my-org-image-paste
  (if my-org-image-paste-mode
      (progn
        (advice-add 'current-kill :around #'my-org-image-paste--current-kill)
        (advice-add 'insert-for-yank :filter-args #'my-org-image-paste--insert-args)
        (advice-add 'insert-for-yank :after #'my-org-image-paste--after-insert))
    (advice-remove 'current-kill #'my-org-image-paste--current-kill)
    (advice-remove 'insert-for-yank #'my-org-image-paste--insert-args)
    (advice-remove 'insert-for-yank #'my-org-image-paste--after-insert)))

(provide 'org-image-paste)
;;; org-image-paste.el ends here
