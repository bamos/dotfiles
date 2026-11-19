;;; org-clipboard-roundtrip-test.el --- Simulated app round trips -*- lexical-binding: t; -*-

(load (expand-file-name "org-rich-copy-test.el" (file-name-directory load-file-name)))

(defun org-clipboard-roundtrip-native-formats (data source)
  "Use the native codec, without accessing the user's real clipboard."
  (let ((helper (my-org-rich-copy--helper)))
    (with-temp-buffer
      (insert (json-encode `((html . ,(plist-get data :html)) (plain . ,(plist-get data :plain))
                             (links . ,(plist-get data :links)) (images . ,(plist-get data :images))
                             (imageOnly . ,(if (plist-get data :image-only) t :json-false))
                             (expected . ,source))))
      (let ((coding-system-for-write 'utf-8-unix) (coding-system-for-read 'utf-8-unix))
        (should (eq 0 (call-process-region (point-min) (point-max) helper t t nil "--convert"))))
      (goto-char (point-min))
      (json-parse-buffer :object-type 'plist))))

(defun org-clipboard-roundtrip-matrix (kind format &optional graphical)
  "Copy KIND through FORMAT, then paste using each command.
Simulate another app by publishing only the selected representation and
removing Emacs's ownership marker.  No installed app or real clipboard is
used.  GRAPHICAL also checks rendered image glyphs."
  (org-rich-copy-test-with-image
    (let* ((source (pcase kind
                     ('text "Read [[https://example.com/one][café 🌎]].\n\nSecond paragraph.\n")
                     ('image "#+ATTR_ORG: :width 120\n[[file:example.png]]\n")
                     ('mixed (concat "Read [[https://example.com/one][café 🌎]].\n\n"
                                     "#+ATTR_ORG: :width 120\n[[file:example.png]]\n"))))
           (org-image-actual-width 96))
      (dolist (copy '(standard evil-char evil-line))
        (org-rich-copy-test-with-clipboard
          (let (original formats data)
            (with-temp-buffer
              (org-mode)
              (evil-local-mode 1)
              (insert source)
              (pcase copy
                ('standard (kill-ring-save (point-min) (point-max)))
                ('evil-char (evil-yank (point-min) (point-max) 'char))
                ('evil-line (evil-yank (point-min) (point-max) 'line)))
              (setq original (car kill-ring) data published
                    formats (org-clipboard-roundtrip-native-formats published source)))
            (dolist (paste '(yank evil-paste-after evil-paste-before))
              (ert-info ((format "%s -> %s (%s) -> %s" copy format kind paste))
                (setq plain (plist-get data :plain) html nil owned nil extra-formats nil)
                (pcase format
                  ('internal (setq html (plist-get data :html)))
                  ('html
                   ;; An app doesn't preserve Emacs's private ownership marker.
                   (setq html (replace-regexp-in-string "<!--[^>]*-->" "" (plist-get formats :html))))
                  ('rtf (setq extra-formats (list (cons 'application/rtf (base64-decode-string (plist-get formats :rtf))))))
                  ('png (setq extra-formats (list (cons 'image/png (base64-decode-string (plist-get formats :png))))))
                  ('tiff (setq extra-formats (list (cons 'image/tiff (base64-decode-string (plist-get formats :tiff)))))))
                (let ((kill-ring (list original)) (kill-ring-yank-pointer nil)
                      (interprogram-paste-function
                       (lambda () (unless (my-org-rich-copy--ours-p) (copy-sequence plain)))))
                  (setq kill-ring-yank-pointer kill-ring)
                  (save-window-excursion
                    (with-temp-buffer
                      (org-mode)
                      (evil-local-mode 1)
                      (evil-normal-state)
                      (when graphical (set-window-buffer (selected-window) (current-buffer)))
                      (if graphical
                          ;; Exercise the actual command loop, especially Evil's
                          ;; linewise p, rather than invoking only helper functions.
                          (execute-kbd-macro (pcase paste ('yank (kbd "s-v"))
                                                  ('evil-paste-after (kbd "p"))
                                                  ('evil-paste-before (kbd "P"))))
                        (call-interactively paste)
                        (cl-letf (((symbol-function 'org-display-inline-images) #'ignore))
                          (run-hooks 'post-command-hook)))
                      (should-not (string-match-p "\u200b" (buffer-string)))
                      (should-not (string-match-p (regexp-quote "\\\\") (buffer-string)))
                      (let* ((links (org-element-map (org-element-parse-buffer) 'link #'identity))
                             (images (cl-remove-if-not (lambda (link) (equal (org-element-property :type link) "file")) links))
                             (web (cl-remove-if-not (lambda (link) (equal (org-element-property :type link) "https")) links)))
                        (should (= (length web) (if (eq kind 'image) 0 1)))
                        (should (= (length images) (if (eq kind 'text) 0 1)))
                        (when web
                          (should (equal (org-element-property :raw-link (car web)) "https://example.com/one"))
                          (should (string-match-p "café 🌎" (buffer-string)))
                          (should (string-match-p "\.\n\n" (buffer-string))))
                        (dolist (link images) (should (file-exists-p (org-element-property :path link))))
                        (when (eq format 'internal)
                          (should (eq (car kill-ring) original))
                          (should (equal (string-trim (buffer-string)) (string-trim source))))
                        (when (and graphical images)
                          (font-lock-ensure)
                          (goto-char (point-min))
                          (set-window-start (selected-window) (point-min))
                          (redisplay t)
                          (should (= (length org-inline-image-overlays) 1))
                          (should (cl-loop for y from 5 below (window-body-height nil t) by 5
                                           thereis (eq (car-safe (posn-object (posn-at-x-y 40 y (selected-window)))) 'image)))
)))))))))))))

(ert-deftest org-clipboard-roundtrip-internal-matrix ()
  (dolist (kind '(text image mixed)) (org-clipboard-roundtrip-matrix kind 'internal)))

(ert-deftest org-clipboard-roundtrip-external-text-matrix ()
  (dolist (format '(html rtf)) (org-clipboard-roundtrip-matrix 'text format)))

(ert-deftest org-clipboard-roundtrip-external-image-matrix ()
  (dolist (format '(html png tiff)) (org-clipboard-roundtrip-matrix 'image format)))

(ert-deftest org-clipboard-roundtrip-external-mixed-matrix ()
  (org-clipboard-roundtrip-matrix 'mixed 'html))

(ert-deftest org-clipboard-roundtrip-images-remain-visible-with-real-paste-keys ()
  (skip-unless (display-graphic-p))
  (dolist (format '(internal html rtf)) (org-clipboard-roundtrip-matrix 'text format t))
  (dolist (format '(internal html png tiff)) (org-clipboard-roundtrip-matrix 'image format t))
  (dolist (format '(internal html)) (org-clipboard-roundtrip-matrix 'mixed format t)))

;;; org-clipboard-roundtrip-test.el ends here
