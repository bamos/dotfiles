;;; org-image-paste-test.el --- Image clipboard paste regressions -*- lexical-binding: t; -*-

;; emacs --batch -Q -l ~/.emacs.d/tests/org-image-paste-test.el -f ert-run-tests-batch-and-exit
;; Load the text regressions too, to check both shared paste modules together.
(load (expand-file-name "org-html-paste-test.el"
                        (file-name-directory load-file-name)))

(defconst org-image-paste-test-png
  (base64-decode-string
   "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII="))

(defmacro org-image-paste-test-with-clipboard (&rest body)
  "Run BODY with an image clipboard and an isolated image directory."
  (declare (indent 0))
  `(let* ((directory (make-temp-file "org-image-paste-test-" t))
          (default-directory (file-name-as-directory directory))
          (my-org-image-paste-directory "images")
          (my-org-image-paste--last-image nil)
          (clipboard-image org-image-paste-test-png)
          (clipboard-html nil)
          (clipboard-rtf nil)
          (clipboard-text nil)
          (clipboard-new nil)
          (clipboard-owned nil)
          (kill-ring nil)
          (kill-ring-yank-pointer nil)
          (select-enable-clipboard t)
          (save-interprogram-paste-before-kill nil)
          (yank-pop-change-selection nil)
          (interprogram-paste-function
           (lambda () (when clipboard-new
                        (setq clipboard-new nil)
                        clipboard-text)))
          (interprogram-cut-function
           (lambda (text)
             (setq clipboard-text text clipboard-image nil clipboard-html nil clipboard-rtf nil
                   clipboard-owned t))))
     (unwind-protect
         (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
                   ((symbol-function 'gui-backend-selection-owner-p)
                    (lambda (&rest _) clipboard-owned))
                   ((symbol-function 'gui-get-selection)
                    (lambda (_selection type)
                      (cond
                       ((eq type 'TARGETS)
                        (vconcat '(TARGETS)
                                 (when clipboard-image '(image/png))
                                 (when clipboard-html '(text/html))
                                 (when clipboard-rtf '(application/rtf))
                                 (when clipboard-text '(STRING))))
                       (clipboard-owned clipboard-text)
                       ((eq type 'image/png) clipboard-image)
                       ((eq type 'text/html) clipboard-html)
                       ((eq type 'application/rtf) clipboard-rtf)
                       ((eq type 'STRING) clipboard-text)))))
           ,@body)
       (delete-directory directory t))))

(ert-deftest org-image-paste-both-commands-save-identical-image-and-reuse-file ()
  (org-image-paste-test-with-clipboard
    (let (first-link)
      (dolist (command '(org-yank evil-paste-after evil-paste-before))
        (with-temp-buffer
          (org-mode)
          (evil-local-mode 1)
          (evil-normal-state)
          (call-interactively command)
          (should (string-match-p "\\`\\[\\[file:images/clipboard-.*\\.png\\]\\]\\'"
                                  (buffer-string)))
          (if first-link
              (should (equal first-link (buffer-string)))
            (setq first-link (buffer-string)))
          (should (equal clipboard-image org-image-paste-test-png))
          (should (memq #'my-org-image-paste--display post-command-hook)))))
    (let ((files (directory-files (expand-file-name "images" directory) t "\\.png\\'")))
      (should (= (length files) 1))
      (with-temp-buffer
        (set-buffer-multibyte nil)
        (insert-file-contents-literally (car files))
        (should (equal (buffer-string) org-image-paste-test-png))))))

(ert-deftest org-image-paste-preview-runs-once ()
  (org-image-paste-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (let ((calls 0))
        (cl-letf (((symbol-function 'org-display-inline-images)
                   (lambda (&rest _) (setq calls (1+ calls)))))
          (run-hooks 'post-command-hook)
          (run-hooks 'post-command-hook)
          (should (= calls 1)))))))

(ert-deftest org-image-paste-existing-links-refresh-after-repaste ()
  (dolist (command '(org-yank evil-paste-after evil-paste-before))
    (org-html-paste-test-with-clipboard "unused" nil
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (let ((source (concat "Read [[https://example.com][Example]].\n\n"
                              "#+ATTR_ORG: :width 120\n[[file:images/example.png]]\n"))
              (calls 0))
          (insert source)
          (evil-yank (point-min) (point-max) 'line)
          (erase-buffer)
          (call-interactively command)
          ;; Evil's linewise p in an empty buffer starts on the next line.
          (should (equal (string-trim (buffer-string)) (string-trim source)))
          (cl-letf (((symbol-function 'org-display-inline-images)
                     (lambda (&rest _) (cl-incf calls))))
            (run-hooks 'post-command-hook)
            (run-hooks 'post-command-hook)
            (should (= calls 1))))))))

(ert-deftest org-image-paste-existing-links-in-registers-and-history ()
  (org-html-paste-test-with-clipboard "unused" nil
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (let ((evil-register-alist nil)
            (source "[[file:images/example.png]]")
            (calls 0))
        (kill-new source)
        (kill-new "Newer text")
        (evil-set-register ?a source)
        (cl-letf (((symbol-function 'org-display-inline-images)
                   (lambda (&rest _) (cl-incf calls))))
          (evil-paste-after 2 ?a)
          (should (equal (buffer-string) (concat source source)))
          (run-hooks 'post-command-hook)
          (should (= calls 1))
          (erase-buffer)
          (yank 2)
          (should (equal (buffer-string) source))
          (run-hooks 'post-command-hook)
          (should (= calls 2)))))))

(ert-deftest org-image-paste-repairs-escaped-width-metadata-on-repaste ()
  (dolist (command '(org-yank evil-paste-after evil-paste-before))
    (org-html-paste-test-with-clipboard "unused" nil
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (kill-new "\u200b#+ATTR_ORG: :width 120\n[[file:images/example.png]]\n")
        (call-interactively command)
        (should (equal (buffer-string) "#+ATTR_ORG: :width 120\n[[file:images/example.png]]\n"))))))

(ert-deftest org-image-paste-reuses-existing-file-after-other-pastes-and-restart ()
  (org-image-paste-test-with-clipboard
    (let ((first (my-org-image-paste--save (cons ".png" clipboard-image))))
      (my-org-image-paste--save '(".png" . "different image bytes"))
      (should (equal first (my-org-image-paste--save (cons ".png" clipboard-image))))
      (setq my-org-image-paste--last-image nil)
      (should (equal first (my-org-image-paste--save (cons ".png" clipboard-image))))
      (should (= 2 (length (directory-files "images" nil "\\.png\\'")))))))

(ert-deftest org-image-paste-never-reuses-a-changed-file ()
  (org-image-paste-test-with-clipboard
    (let* ((image (cons ".png" clipboard-image))
           (first (my-org-image-paste--save image))
           (file (nth 2 my-org-image-paste--last-image)))
      (write-region (make-string (length clipboard-image) ?x) nil file nil 'silent)
      (should-not (equal first (my-org-image-paste--save image)))
      (delete-file (nth 2 my-org-image-paste--last-image))
      (let ((previous (nth 2 my-org-image-paste--last-image)))
        (my-org-image-paste--save image)
        (should-not (equal previous (nth 2 my-org-image-paste--last-image)))))))

(ert-deftest org-image-paste-metadata-repair-preserves-literal-examples ()
  (dolist (source '("\u200b#+TITLE: Literal title\n[[file:example.png]]\n"
                    "\u200b#+ATTR_ORG: :width 120\nOrdinary prose.\n"
                    "#+begin_example\n\u200b#+ATTR_ORG: :width 120\n[[file:example.png]]\n#+end_example\n"))
    (should (equal (my-org-paste-clean-image-metadata source) source))))

(ert-deftest org-image-paste-preview-ignores-text-and-code-blocks ()
  (org-html-paste-test-with-clipboard "unused" nil
    (dolist (source '("Ordinary text" "[[file:example.txt]]"
                      "[[https://example.com/image.png][Website]]"))
      (with-temp-buffer
        (org-mode)
        (kill-new source)
        (org-yank)
        (should-not (memq #'my-org-image-paste--display post-command-hook))))
    (dolist (kind '("src text" "example" "export html"))
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_" kind "\n\n#+end_" (car (split-string kind)) "\n")
        (goto-char (point-min))
        (forward-line)
        (kill-new "[[file:images/example.png]]")
        (org-yank)
        (should-not (memq #'my-org-image-paste--display post-command-hook))))
    (with-temp-buffer
      (text-mode)
      (kill-new "[[file:images/example.png]]")
      (yank)
      (should-not (memq #'my-org-image-paste--display post-command-hook)))))

(ert-deftest org-image-paste-prefers-html-text-over-image-preview ()
  (org-image-paste-test-with-clipboard
    (setq clipboard-html org-html-paste-test-html
          clipboard-text org-html-paste-test-plain
          clipboard-new t)
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-org)))
    (should-not (file-directory-p (expand-file-name "images" directory)))))

(ert-deftest org-image-paste-prefers-rtf-text-over-image-preview ()
  (org-image-paste-test-with-clipboard
    (setq clipboard-rtf org-html-paste-test-rtf
          clipboard-text org-html-paste-test-rtf-plain
          clipboard-new t)
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-rtf-org)))
    (should-not (file-directory-p (expand-file-name "images" directory)))))

(ert-deftest org-image-paste-rtf-attachment-placeholder-does-not-hide-image ()
  (org-image-paste-test-with-clipboard
    (setq clipboard-rtf "{\\rtf1\\ansi\\uc1\\u65532?}"
          clipboard-text "\ufffc"
          clipboard-new t)
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (string-prefix-p "[[file:images/" (buffer-string))))))

(ert-deftest org-image-paste-browser-copy-image-allows-html-img ()
  (org-image-paste-test-with-clipboard
    (setq clipboard-html "<html><body><img src=\"https://example.com/image.png\"></body></html>"
          clipboard-text "https://example.com/image.png"
          clipboard-new t)
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (string-prefix-p "[[file:images/" (buffer-string))))))

(ert-deftest org-image-paste-respects-named-registers-and-history ()
  (org-image-paste-test-with-clipboard
    (let ((evil-register-alist nil)
          (kill-ring '("new text" "older text")))
      (setq kill-ring-yank-pointer kill-ring)
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (evil-set-register ?a "named text")
        (evil-paste-after 1 ?a)
        (should (equal (buffer-string) "named text"))
        (erase-buffer)
        (yank 2)
        (should (equal (buffer-string) "older text"))))
    (should-not (file-directory-p (expand-file-name "images" directory)))))

(ert-deftest org-image-paste-evil-count-placement-visual-and-undo ()
  (org-image-paste-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (buffer-enable-undo)
      (insert "ab")
      (goto-char (point-min))
      (undo-boundary)
      (evil-paste-after 2)
      (should (equal (buffer-string) (concat "a" (car kill-ring) (car kill-ring) "b")))
      (undo-boundary)
      (undo-only 1)
      (should (equal (buffer-string) "ab"))
      (evil-visual-select (point-min) (point-max) 'char)
      (evil-paste-after 1)
      (should (string-prefix-p "[[file:images/" (buffer-string)))
      (should (string-suffix-p "]]" (buffer-string))))))

(ert-deftest org-image-paste-saves-beside-note-not-working-directory ()
  (org-image-paste-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (setq buffer-file-name (expand-file-name "notes/note.org" directory))
      (org-yank)
      (should (file-directory-p (expand-file-name "notes/images" directory)))
      (should (string-prefix-p "[[file:images/" (buffer-string))))))

(ert-deftest org-image-paste-internal-text-is-never-an-image ()
  (dolist (source '("  \n\n" "<img src=\"literal.png\">"))
    (org-image-paste-test-with-clipboard
      (with-temp-buffer
        (org-mode)
        (kill-new (copy-sequence source))
        (org-yank '(4))
        (should (equal (buffer-string) source))
        (should-not (file-directory-p (expand-file-name "images" directory)))))))

(ert-deftest org-image-paste-unadvertised-image-is-ignored-without-ownership ()
  (org-image-paste-test-with-clipboard
    (with-temp-buffer
      (org-mode)
      (kill-new "  \n\n")
      (cl-letf (((symbol-function 'gui-backend-selection-owner-p)
                 (lambda (&rest _) nil)))
        (org-yank '(4)))
      (should (equal (buffer-string) "  \n\n"))
      (should-not (file-directory-p (expand-file-name "images" directory))))))

;;; org-image-paste-test.el ends here
