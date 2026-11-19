;;; org-rich-copy-test.el --- Outbound Org clipboard tests -*- lexical-binding: t; -*-

(load (expand-file-name "org-image-paste-test.el"
                        (file-name-directory load-file-name)))
(load (expand-file-name "../org-rich-copy.el"
                        (file-name-directory load-file-name)))

(ert-deftest org-rich-copy-renders-links-and-unicode-without-formatting ()
  (let ((data (my-org-rich-copy--render
               "Read [[https://example.com/a?x=1&y=2][café & guide]] and [[mailto:test@example.com][mail]].\n")))
    (should (equal (plist-get data :plain) "Read café & guide and mail.\n"))
    (should (string-match-p (regexp-quote "href=\"https://example.com/a?x=1&amp;y=2\"") (plist-get data :html)))
    (should (string-match-p "café &amp; guide</a>" (plist-get data :html)))
    (should (string-match-p "href=\"mailto:test@example.com\"" (plist-get data :html)))))

(defmacro org-rich-copy-test-with-image (&rest body)
  (declare (indent 0))
  `(let* ((directory (make-temp-file "org-copy-image-" t))
          (default-directory (file-name-as-directory directory))
          (file (expand-file-name "example.png" directory)))
     (unwind-protect
         (progn
           (let ((coding-system-for-write 'no-conversion))
             (write-region org-image-paste-test-png nil file nil 'silent))
           ,@body)
       (delete-directory directory t))))

(ert-deftest org-rich-copy-image-exports-pixels-without-org-metadata ()
  (org-rich-copy-test-with-image
    (dolist (source '("[[file:example.png]]"
                      "#+ATTR_ORG: :width 120\n[[file:example.png]]\n"
                      "\u200b#+ATTR_ORG: :width 120\n[[file:example.png]]\n"))
      (let* ((data (my-org-rich-copy--render source))
             (images (plist-get data :images)))
        (should data)
        (should (= (length images) 1))
        (should (plist-get data :image-only))
        (should (equal (alist-get 'path (aref images 0)) file))
        (should (string-match-p "<img .*src=\"data:image/png;base64," (plist-get data :html)))
        (should-not (string-match-p "ATTR_ORG\\|\\[\\[file:" (plist-get data :html)))
        (should-not (string-match-p "ATTR_ORG\\|\\[\\[file:" (plist-get data :plain)))))))

(ert-deftest org-rich-copy-images-resolve-beside-the-note ()
  (org-rich-copy-test-with-image
    (with-temp-buffer
      (setq buffer-file-name (expand-file-name "note.org" directory)
            default-directory temporary-file-directory)
      (let ((data (my-org-rich-copy--render "[[file:example.png]]")))
        (should (equal (alist-get 'path (aref (plist-get data :images) 0)) file))))))

(ert-deftest org-rich-copy-native-images-and-mixed-content-are-portable ()
  (skip-unless (eq system-type 'darwin))
  (org-rich-copy-test-with-image
    (dolist (source '("#+ATTR_ORG: :width 120\n[[file:example.png]]\n"
                      "🌎 [[https://example.com][Example]]\n\n#+ATTR_ORG: :width 120\n[[file:example.png]]\n"
                      "[[file:example.png]] [[file:example.png]]"))
      (let* ((data (my-org-rich-copy--render source))
             (helper (my-org-rich-copy--helper))
             (image-only (plist-get data :image-only)))
        (with-temp-buffer
          (insert (json-encode `((html . ,(plist-get data :html)) (plain . ,(plist-get data :plain))
                                 (links . ,(plist-get data :links)) (images . ,(plist-get data :images))
                                 (imageOnly . ,(if image-only t :json-false)) (expected . ,source))))
          (let ((coding-system-for-write 'utf-8-unix) (coding-system-for-read 'utf-8-unix))
            (should (eq 0 (call-process-region (point-min) (point-max) helper t t nil "--self-test"))))
          (goto-char (point-min))
          (let ((result (json-parse-buffer :object-type 'plist :false-object nil)))
            (should (equal (plist-get result :html) t))
            (should (= (plist-get result :attachments) (length (plist-get data :images))))
            (should (= (plist-get result :links) (length (plist-get data :links))))
            (should (eq (plist-get result :png) image-only))
            (should (eq (plist-get result :tiff) image-only))
            (when image-only
              (should (= (plist-get result :imageWidth) 1))
              (should (= (plist-get result :imageHeight) 1)))
            (should-not (string-match-p "ATTR_ORG\\|\\[\\[file:" (plist-get result :plain)))))))))

(ert-deftest org-rich-copy-image-code-and-missing-files-stay-literal ()
  (org-rich-copy-test-with-image
    (dolist (source '("[[file:missing.png]]" "[[file:/ssh:example:/image.png]]"
                      "#+begin_src text\n[[file:example.png]]\n#+end_src\n"
                      "#+begin_example\n[[file:example.png]]\n#+end_example\n"))
      (should-not (my-org-rich-copy--render source)))))

(ert-deftest org-rich-copy-preserves-whitespace-and-escapes-html ()
  (let ((data (my-org-rich-copy--render
               "<script>\n  [[https://example.com][Example]]  next\n\nlast\n")))
    (should (equal (plist-get data :plain) "<script>\n  Example  next\n\nlast\n"))
    (should (string-match-p "&lt;script&gt;" (plist-get data :html)))))

(ert-deftest org-rich-copy-paragraphs-roundtrip-through-html-without-break-markers ()
  (let* ((source (concat "Read [[https://example.com/one][First]].\n\n"
                         "Read [[https://example.com/two][Second]].\n\nLast paragraph."))
         (data (my-org-rich-copy--render source)))
    (should (equal (my-org-html-paste--convert (plist-get data :html) (plist-get data :plain))
                   source))))

(ert-deftest org-rich-copy-native-ranges-use-utf16-units ()
  (let* ((data (my-org-rich-copy--render "🌎 [[https://example.com][café 🌟]]"))
         (link (aref (plist-get data :links) 0)))
    (should (= (alist-get 'start link) 3))
    (should (= (alist-get 'length link) 7))))

(ert-deftest org-rich-copy-only-complete-links-outside-code-blocks ()
  (dolist (text '("No links\n" "[[https://example.com][partial"
                  "#+begin_src text\n[[https://example.com][Example]]\n#+end_src\n"
                  "#+begin_example\n[[https://example.com][Example]]\n#+end_example\n"
                  "[[file:example.png]]" "[[javascript:alert(1)][Example]]"))
    (should-not (my-org-rich-copy--render text))))

(ert-deftest org-rich-copy-does-not-export-directives ()
  (let ((html (plist-get (my-org-rich-copy--render
                          "#+INCLUDE: \"missing-example-file\"\n[[https://example.com][Example]]") :html)))
    (should (string-match-p (regexp-quote "#+INCLUDE:") html))
    (should (string-match-p "missing-example-file" html))))

(ert-deftest org-rich-copy-native-rtf-retains-hyperlink-and-unicode ()
  (skip-unless (eq system-type 'darwin))
  (let* ((data (my-org-rich-copy--render "See [[https://example.com/guide][café guide]]."))
         (helper (my-org-rich-copy--helper)))
    (with-temp-buffer
      (insert (json-encode `((html . ,(plist-get data :html)) (plain . ,(plist-get data :plain))
                             (links . ,(plist-get data :links)))))
      (let ((coding-system-for-write 'utf-8-unix) (coding-system-for-read 'utf-8-unix))
        (should (eq 0 (call-process-region (point-min) (point-max) helper t t nil "--convert"))))
      (goto-char (point-min))
      (let* ((result (json-parse-buffer :object-type 'plist))
             (rtf (base64-decode-string (plist-get result :rtf))))
        (should (string-match-p "HYPERLINK" rtf))
        (should (string-match-p "https://example.com/guide" rtf))
        (should (string-match-p "café guide" (plist-get result :text)))
        (should (equal (my-org-html-paste--convert rtf "See café guide." 'rtf)
                       "See [[https://example.com/guide][café guide]]."))))))

(ert-deftest org-rich-copy-native-pasteboard-publishes-all-three-formats ()
  (skip-unless (eq system-type 'darwin))
  (let* ((source "Read [[https://example.com][café 🌎]].")
         (data (my-org-rich-copy--render source))
         (helper (my-org-rich-copy--helper)))
    (with-temp-buffer
      (insert (json-encode `((html . ,(plist-get data :html)) (plain . ,(plist-get data :plain))
                             (links . ,(plist-get data :links)) (expected . ,source))))
      (let ((coding-system-for-write 'utf-8-unix) (coding-system-for-read 'utf-8-unix))
        (should (eq 0 (call-process-region (point-min) (point-max) helper t t nil "--self-test"))))
      (goto-char (point-min))
      (let ((result (json-parse-buffer :object-type 'plist)))
        (should (equal (plist-get result :plain) "Read café 🌎."))
        (should (eq (plist-get result :html) t))
        (should (= (plist-get result :links) 1))))))

(defmacro org-rich-copy-test-with-clipboard (&rest body)
  "Exercise the normal copy/paste path without touching the real clipboard."
  (declare (indent 0))
  `(let ((my-org-rich-copy--last nil)
         (my-org-rich-copy-mode nil)
         (kill-ring nil) (kill-ring-yank-pointer nil)
         (interprogram-cut-function #'gui-select-text)
         (interprogram-paste-function #'gui-selection-value)
         (select-enable-clipboard t) (select-enable-primary nil)
         (save-interprogram-paste-before-kill nil)
         (yank-pop-change-selection nil)
         plain html owned published extra-formats)
     (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
               ((symbol-function 'gui-set-selection)
                (lambda (_ text) (setq plain text html nil owned t)))
               ((symbol-function 'gui-get-selection)
                (lambda (_ type)
                  (pcase type
                    ('TARGETS (vconcat (if html [TARGETS STRING text/html] [TARGETS STRING])
                                       (mapcar #'car extra-formats)))
                    ('STRING plain)
                    ('text/html html)
                    (_ (cdr (assq type extra-formats))))))
               ((symbol-function 'gui-backend-selection-owner-p) (lambda (_) owned))
               ((symbol-function 'my-org-rich-copy--write)
                (lambda (data _)
                  (setq published data plain (plist-get data :plain) html (plist-get data :html) owned nil)
                  t)))
       (unwind-protect
           (progn (my-org-rich-copy-mode 1) ,@body)
         (my-org-rich-copy-mode -1)))))

(ert-deftest org-rich-copy-standard-copy-keeps-exact-internal-text ()
  (org-rich-copy-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (insert "Read [[https://example.com][Example]].\n\n")
      (let ((source (buffer-string)))
        (kill-ring-save (point-min) (point-max))
        (should (equal plain "Read Example.\n\n"))
        (should html)
        (should-not (my-org-paste-clipboard-types))
        (should-not (gui-selection-value))
        (should (eq (current-kill 0) (car kill-ring)))
        (should (equal (current-kill 0) source))
        (erase-buffer)
        (org-yank)
        (should (equal (buffer-string) source))))))

(ert-deftest org-rich-copy-image-keeps-original-link-and-evil-line-properties ()
  (org-rich-copy-test-with-image
    (org-rich-copy-test-with-clipboard
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (let ((source "#+ATTR_ORG: :width 120\n[[file:example.png]]\n"))
          (insert source)
          (evil-yank (point-min) (point-max) 'line)
          (should (my-org-rich-copy--ours-p))
          (should (eq (current-kill 0) (car kill-ring)))
          (should (eq (car (get-text-property 0 'yank-handler (car kill-ring))) 'evil-yank-line-handler))
          (goto-char (point-min))
          (evil-paste-before 2)
          (should (equal (buffer-string) (concat source source source)))
          (should-not (file-exists-p (expand-file-name "images" directory))))))))

(ert-deftest org-rich-copy-repasted-image-is-visible-in-graphical-emacs ()
  (skip-unless (display-graphic-p))
  (org-rich-copy-test-with-clipboard
    (let* ((directory (make-temp-file "org-repaste-image-" t))
           (default-directory (file-name-as-directory directory))
           (org-image-actual-width nil)
           (source (concat "Read [[https://example.com][Example]].\n\n"
                           "#+ATTR_ORG: :width 120\n[[file:example.png]]\n")))
      (unwind-protect
          (progn
            (let ((coding-system-for-write 'no-conversion))
              (write-region org-image-paste-test-png nil
                            (expand-file-name "example.png" directory) nil 'silent))
            (dolist (command '(org-yank evil-paste-after evil-paste-before))
              (save-window-excursion
                (with-temp-buffer
                  (org-mode)
                  (evil-local-mode 1)
                  (evil-normal-state)
                  (set-window-buffer (selected-window) (current-buffer))
                  (insert source)
                  (font-lock-ensure)
                  (org-display-inline-images)
                  (should (= (length org-inline-image-overlays) 1))
                  (kill-ring-save (point-min) (point-max))
                  (should (my-org-rich-copy--ours-p))
                  (erase-buffer)
                  (org-remove-inline-images)
                  (call-interactively command)
                  (run-hooks 'post-command-hook)
                  (font-lock-ensure)
                  (goto-char (point-min))
                  (redisplay t)
                  (should (equal (buffer-string) source))
                  (should (= (length org-inline-image-overlays) 1))
                  ;; An overlay can exist while the image is invisible.  Check
                  ;; actual rendered glyphs, as in the hidden-width regression.
                  (should
                   (cl-loop for y from 5 below (window-body-height nil t) by 5
                            thereis (eq (car-safe (posn-object
                                                  (posn-at-x-y 40 y (selected-window))))
                                        'image)))))))
        (delete-directory directory t)))))

(ert-deftest org-rich-copy-evil-counted-line-paste-is-lossless ()
  (org-rich-copy-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (let ((source "* TODO [[https://example.com/task][Example task]]\nDEADLINE: <2030-01-02 Wed>\n"))
        (insert source)
        (evil-yank (point-min) (point-max) 'line)
        (should html)
        (goto-char (point-min))
        (evil-paste-before 2)
        (should (equal (buffer-string) (concat source source source)))))))

(ert-deftest org-rich-copy-external-copy-with-same-label-is-still-imported ()
  (org-rich-copy-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (kill-new "[[https://example.com/first][Example]]")
      (should (my-org-rich-copy--ours-p))
      (setq html "<p><a href=\"https://example.com/second\">Example</a></p>")
      (should-not (my-org-rich-copy--ours-p))
      (should (equal (current-kill 0) "[[https://example.com/second][Example]]")))))

(ert-deftest org-rich-copy-other-modes-and-source-selections-stay-plain ()
  (org-rich-copy-test-with-clipboard
    (with-temp-buffer
      (fundamental-mode)
      (kill-new "[[https://example.com][Example]]")
      (should-not html)
      (org-mode)
      (insert "#+begin_src text\n[[https://example.com][Example]]\n#+end_src\n")
      (goto-char (point-min))
      (forward-line 1)
      (kill-new "[[https://example.com][Example]]")
      (should-not html))))

(ert-deftest org-rich-copy-failure-keeps-plain-clipboard-and-kill-ring ()
  (org-rich-copy-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (cl-letf (((symbol-function 'my-org-rich-copy--write) (lambda (&rest _) (error "Example failure"))))
        (kill-new "[[https://example.com][Example]]"))
      (should-not html)
      (should (equal plain "[[https://example.com][Example]]"))
      (should (equal (current-kill 0) plain)))))

;;; org-rich-copy-test.el ends here
