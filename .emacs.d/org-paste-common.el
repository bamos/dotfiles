;;; org-paste-common.el --- Validate external clipboard formats -*- lexical-binding: t; -*-

(require 'select)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'image)
(require 'subr-x)

(defvar my-org-paste-internal-clipboard-functions nil
  "Functions recognizing clipboard data written by our native helpers.")

(defun my-org-paste-clean-image-metadata (text)
  "Repair Pandoc's invisible escape before an image's width attribute.
Only repair a width line immediately before a standalone local image link;
leave literal examples, other directives, and the string's properties alone."
  (if (not (string-match-p "\u200b#\\+ATTR_ORG:" text)) text
    (with-temp-buffer
      (let ((org-inhibit-startup t) (org-mode-hook nil)) (org-mode))
      (insert text)
      (let (positions)
        (org-element-map (org-element-parse-buffer) 'link
          (lambda (link)
            (when (and (member (org-element-property :type link) '("file" "attachment"))
                       (string-match-p (image-file-name-regexp) (org-element-property :path link)))
              (goto-char (org-element-begin link))
              (when (and (string-blank-p (buffer-substring-no-properties
                                          (line-beginning-position) (point)))
                         (string-blank-p (buffer-substring-no-properties
                                          (- (org-element-end link) (org-element-post-blank link))
                                          (line-end-position))))
                (forward-line -1)
                (when (looking-at "[ \t]*\\(\u200b\\)#\\+ATTR_ORG:.*:width[ \t]+[0-9]+\\b.*$")
                  (push (match-beginning 1) positions))))))
        (dolist (position (sort positions #'>)) (delete-region position (1+ position))))
      (buffer-string))))

(defun my-org-paste-clipboard-types ()
  "Return the formats advertised by an external graphical clipboard.
On NS, requesting HTML or image data for an Emacs-owned selection can
return the original text regardless of the requested type.  Check both
ownership and TARGETS before treating any selection as rich content."
  (when (and select-enable-clipboard (display-graphic-p)
             (not (gui-backend-selection-owner-p 'CLIPBOARD))
             (not (run-hook-with-args-until-success 'my-org-paste-internal-clipboard-functions)))
    (ignore-errors
      (append (gui-get-selection 'CLIPBOARD 'TARGETS) nil))))

(defun my-org-paste-clipboard-data (type types)
  "Read clipboard TYPE only when it is advertised in TYPES."
  (when (and (memq type types)
             (not (gui-backend-selection-owner-p 'CLIPBOARD)))
    (ignore-errors (gui-get-selection 'CLIPBOARD type))))

(defun my-org-paste-clipboard-text (types)
  "Return the plain text representation advertised in TYPES."
  (cl-loop for type in '(STRING UTF8_STRING text/plain\;charset=utf-8 text/plain TEXT)
           for data = (my-org-paste-clipboard-data type types)
           when (stringp data) return data))

(defun my-org-paste-clipboard-rich-text (types)
  "Return (FORMAT . DATA) for rich text advertised in TYPES.
Prefer HTML when available, then RTF (including its text/rtf alias)."
  (cl-loop for (type . format) in '((text/html . html)
                                   (application/rtf . rtf)
                                   (text/rtf . rtf))
           for data = (my-org-paste-clipboard-data type types)
           when (and (stringp data) (> (length data) 0))
           return (cons format data)))

(provide 'org-paste-common)
;;; org-paste-common.el ends here
