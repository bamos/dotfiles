;;; org-html-paste-test.el --- HTML clipboard paste regressions -*- lexical-binding: t; -*-

;; emacs --batch -Q -l ~/.emacs.d/tests/org-html-paste-test.el -f ert-run-tests-batch-and-exit
(require 'ert)
(require 'package)
(package-initialize)
(require 'evil)
(load (expand-file-name "../org-html-paste.el"
                        (file-name-directory load-file-name)))
(load (expand-file-name "../org-image-paste.el"
                        (file-name-directory load-file-name)))
(my-org-html-paste-mode 1)
(my-org-image-paste-mode 1)

(defmacro org-html-paste-test-with-clipboard (plain html &rest body)
  "Run BODY with a simulated PLAIN/HTML clipboard and a private kill ring."
  (declare (indent 2))
  `(let* ((clipboard-text ,plain)
          (clipboard-html ,html)
          (clipboard-rtf nil)
          (clipboard-rtf-type 'application/rtf)
          (clipboard-new t)
          (clipboard-owned nil)
          (kill-ring nil)
          (kill-ring-yank-pointer nil)
          (kill-do-not-save-duplicates nil)
          (save-interprogram-paste-before-kill nil)
          (select-enable-clipboard t)
          (yank-pop-change-selection nil)
          (my-org-html-paste--entries (make-hash-table :test 'eq))
          (interprogram-paste-function
           (lambda ()
             (when clipboard-new
               (setq clipboard-new nil)
               (copy-sequence clipboard-text))))
          (interprogram-cut-function
           (lambda (text)
             (setq clipboard-text text clipboard-html nil clipboard-rtf nil clipboard-new nil
                   clipboard-owned t))))
     (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
               ((symbol-function 'gui-backend-selection-owner-p)
                (lambda (&rest _) clipboard-owned))
               ((symbol-function 'gui-get-selection)
                (lambda (_selection type)
                  (cond
                   ((eq type 'TARGETS)
                    (vconcat '(TARGETS STRING)
                             (when clipboard-html '(text/html))
                             (when clipboard-rtf (list clipboard-rtf-type))))
                   ;; The NS backend returns its local selection regardless
                   ;; of the requested type, except for TARGETS.
                   (clipboard-owned clipboard-text)
                   ((eq type 'text/html) clipboard-html)
                   ((eq type clipboard-rtf-type) clipboard-rtf)
                   ((eq type 'STRING) clipboard-text)))))
       ,@body)))

(defconst org-html-paste-test-html
  "<p>Read <a href=\"https://example.com/a?x=1&amp;y=2\">café docs</a>.</p>")
(defconst org-html-paste-test-plain "Read café docs.")
(defconst org-html-paste-test-org
  "Read [[https://example.com/a?x=1&y=2][café docs]].")

(defconst org-html-paste-test-rtf
  (concat "{\\rtf1\\ansi\\ansicpg1252\\deff0{\\fonttbl{\\f0 Helvetica;}}"
          "\\uc1\\pard\\f0\\fs24 {\\b Example Editor} supports "
          "{\\field{\\*\\fldinst{HYPERLINK \"https://example.com/editing\"}}"
          "{\\fldrslt{editing}}}, "
          "{\\field{\\*\\fldinst{HYPERLINK \"https://example.com/extensions\"}}"
          "{\\fldrslt{extensions}}}, and "
          "{\\field{\\*\\fldinst{HYPERLINK \"https://example.com/guide?x=1&y=2\"}}"
          "{\\fldrslt{caf\\u233? documentation}}}.\\par}")
  "Synthetic RTF with TextEdit-style links; contains no copied user text.")
(defconst org-html-paste-test-rtf-plain
  "Example Editor supports editing, extensions, and café documentation.\n")
(defconst org-html-paste-test-rtf-org
  (concat "Example Editor supports [[https://example.com/editing][editing]], "
          "[[https://example.com/extensions][extensions]], and "
          "[[https://example.com/guide?x=1&y=2][café documentation]].\n"))

(ert-deftest org-html-paste-textedit-rtf-preserves-links-with-both-commands ()
  (dolist (command '(org-yank evil-paste-after evil-paste-before))
    (org-html-paste-test-with-clipboard org-html-paste-test-rtf-plain nil
      (setq clipboard-rtf org-html-paste-test-rtf)
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (call-interactively command)
        (should (equal (buffer-string) org-html-paste-test-rtf-org))
        (should (equal (car kill-ring) org-html-paste-test-rtf-plain))
        (erase-buffer)
        (call-interactively command)
        (should (equal (buffer-string) org-html-paste-test-rtf-org))))))

(ert-deftest org-html-paste-text-rtf-alias ()
  (org-html-paste-test-with-clipboard org-html-paste-test-rtf-plain nil
    (setq clipboard-rtf org-html-paste-test-rtf clipboard-rtf-type 'text/rtf)
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-rtf-org)))))

(ert-deftest org-html-paste-rtf-history-other-modes-and-source-blocks ()
  (org-html-paste-test-with-clipboard org-html-paste-test-rtf-plain nil
    (setq clipboard-rtf org-html-paste-test-rtf)
    (with-temp-buffer
      (text-mode)
      (yank)
      (should (equal (buffer-string) org-html-paste-test-rtf-plain)))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_src text\n\n#+end_src\n")
      (goto-char (point-min))
      (forward-line)
      (org-yank)
      (should-not (string-match-p "https://" (buffer-string))))
    (kill-new "New internal copy")
    (with-temp-buffer
      (org-mode)
      (yank 2)
      (should (equal (buffer-string) org-html-paste-test-rtf-org)))))

(ert-deftest org-html-paste-prefers-html-when-rtf-is-also-present ()
  (org-html-paste-test-with-clipboard org-html-paste-test-plain org-html-paste-test-html
    (setq clipboard-rtf "This representation should not be read")
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-org)))))

(ert-deftest org-html-paste-rtf-preserves-literal-codepage-bytes ()
  (should (equal (my-org-html-paste--convert
                  (encode-coding-string "{\\rtf1\\ansi\\ansicpg1252 café}" 'windows-1252)
                  "café" 'rtf)
                 "café")))

(ert-deftest org-html-paste-invalid-rtf-falls-back-to-plain-text ()
  (org-html-paste-test-with-clipboard "Keep this plain text" nil
    (setq clipboard-rtf "not an RTF document")
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) "Keep this plain text")))))

(ert-deftest org-html-paste-both-commands-preserve-links-and-repeat ()
  (dolist (command '(org-yank evil-paste-after evil-paste-before))
    (org-html-paste-test-with-clipboard
        org-html-paste-test-plain org-html-paste-test-html
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (call-interactively command)
        (should (equal (buffer-string) org-html-paste-test-org))
        (should (equal (car kill-ring) org-html-paste-test-plain))
        (erase-buffer)
        (call-interactively command)
        (should (equal (buffer-string) org-html-paste-test-org))))))

(ert-deftest org-html-paste-other-modes-and-history-keep-original-text ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (with-temp-buffer
      (text-mode)
      (yank)
      (should (equal (buffer-string) org-html-paste-test-plain)))
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-org))
      ;; An internal copy replaces the external clipboard.
      (kill-new "Internal copy")
      (erase-buffer)
      (org-yank)
      (should (equal (buffer-string) "Internal copy"))
      (erase-buffer)
      (yank 2)
      (should (equal (buffer-string) org-html-paste-test-org)))
    (with-temp-buffer
      (text-mode)
      (let ((kill-ring-yank-pointer kill-ring))
        (yank 2))
      (should (equal (buffer-string) org-html-paste-test-plain)))))

(ert-deftest org-html-paste-plain-text-is-unchanged ()
  (org-html-paste-test-with-clipboard "Plain café\nsecond line\n" nil
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) "Plain café\nsecond line\n")))))

(ert-deftest org-html-paste-code-blocks-stay-plain ()
  (dolist (kind '("src text" "example" "export html"))
    (org-html-paste-test-with-clipboard
        org-html-paste-test-plain org-html-paste-test-html
      (with-temp-buffer
        (org-mode)
        (insert "#+begin_" kind "\n\n#+end_" (car (split-string kind)) "\n")
        (goto-char (point-min))
        (forward-line)
        (org-yank)
        (should (string-match-p (regexp-quote org-html-paste-test-plain)
                                (buffer-string)))
        (should-not (string-match-p "https://" (buffer-string)))))))

(ert-deftest org-html-paste-internal-copy-does-not-inherit-html ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (kill-new (copy-sequence org-html-paste-test-plain))
      (erase-buffer)
      (org-yank)
      (should (equal (buffer-string) org-html-paste-test-plain)))))

(ert-deftest org-html-paste-evil-count-placement-and-register ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (insert "ab")
      (goto-char (point-min))
      (evil-paste-after 2)
      (should (equal (buffer-string)
                     (concat "a" org-html-paste-test-org org-html-paste-test-org "b")))
      (erase-buffer)
      (let ((evil-register-alist nil))
        (evil-set-register ?a "named register")
        (evil-paste-after 1 ?a)
        (should (equal (buffer-string) "named register"))))))

(ert-deftest org-html-paste-evil-linewise-internal-copy ()
  (org-html-paste-test-with-clipboard "unused" nil
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (insert "first\nsecond\n")
      (evil-yank (point-min) (+ (point-min) 6) 'line)
      (goto-char (point-min))
      (evil-paste-after 1)
      (should (equal (buffer-string) "first\nfirst\nsecond\n")))))

(ert-deftest org-html-paste-internal-two-line-todo-counted-paste ()
  (org-html-paste-test-with-clipboard "unused" nil
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (let ((source "* TODO Example task\nDEADLINE: <2000-01-03 Mon>\n"))
        (insert source)
        (evil-yank (point-min) (point-max) 'line)
        (goto-char (1- (point-max)))
        (evil-paste-after 2)
        (should (equal (buffer-string) (concat source source source)))
        (goto-char (1- (point-max)))
        (evil-paste-after 1)
        (should (equal (buffer-string) (concat source source source source)))
        (should (eq (car (get-text-property 0 'yank-handler (car kill-ring)))
                    'evil-yank-line-handler))))))

(ert-deftest org-html-paste-internal-literal-markup-and-whitespace ()
  (dolist (source '("<b>literal HTML</b>\n  indentation\n\n"
                    "| a | b |\n| 1 | 2 |\n"
                    ":PROPERTIES:\n:ID: task-id\n:END:\n"
                    "#+begin_src python\n  print('<tag>')\n#+end_src\n"
                    "[[https://example.com][link]]\n*bold* =code=\n"))
    (org-html-paste-test-with-clipboard "unused" nil
      (with-temp-buffer
        (org-mode)
        (kill-new (copy-sequence source))
        (org-yank '(4))
        (should (equal (buffer-string) source))))))

(ert-deftest org-html-paste-exact-2pp-keys-match-normal-evil ()
  (let (baseline actual)
    (unwind-protect
        (dolist (enabled '(nil t))
          (my-org-html-paste-mode (if enabled 1 -1))
          (my-org-image-paste-mode (if enabled 1 -1))
          (org-html-paste-test-with-clipboard "unused" nil
            (save-window-excursion
              (with-temp-buffer
                (switch-to-buffer (current-buffer))
                (org-mode)
                (evil-local-mode 1)
                (evil-normal-state)
                (insert "* TODO Example task\nDEADLINE: <2000-01-03 Mon>\n")
                (goto-char (point-min))
                (execute-kbd-macro (kbd "2 y y"))
                (forward-line 1)
                (execute-kbd-macro (kbd "2 p p"))
                (if enabled
                    (setq actual (buffer-string))
                  (setq baseline (buffer-string)))))))
      (my-org-html-paste-mode 1)
      (my-org-image-paste-mode 1))
    (should (equal actual baseline))
    (should (= (cl-count ?\n actual) 8))))

(ert-deftest org-html-paste-internal-block-and-character-copies-keep-handlers ()
  (dolist (type '(block char line))
    (org-html-paste-test-with-clipboard "unused" nil
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (insert "one a\none b\n")
        (evil-yank (point-min) (- (point-max) 2) type)
        (let ((original (car kill-ring)))
          (should (eq (current-kill 0) original)))))))

(ert-deftest org-html-paste-unadvertised-html-is-ignored-even-without-ownership ()
  (org-html-paste-test-with-clipboard "unused" nil
    (with-temp-buffer
      (org-mode)
      (kill-new "first\nsecond\n")
      ;; Some backends cannot reliably report ownership.  TARGETS must
      ;; independently prevent treating a plain selection as HTML.
      (cl-letf (((symbol-function 'gui-backend-selection-owner-p)
                 (lambda (&rest _) nil)))
        (org-yank '(4)))
      (should (equal (buffer-string) "first\nsecond\n")))))

(ert-deftest org-html-paste-reload-clears-misclassified-history ()
  (org-html-paste-test-with-clipboard "unused" nil
    (let ((source (copy-sequence "first\nsecond\n")))
      (kill-new source)
      (puthash source (cons source "first second\n") my-org-html-paste--entries)
      (load (expand-file-name "../org-html-paste.el"
                              (file-name-directory (symbol-file
                                                    'org-html-paste-test-with-clipboard))))
      (with-temp-buffer
        (org-mode)
        (org-yank '(4))
        (should (equal (buffer-string) source))))))

(ert-deftest org-html-paste-evil-visual-replacement ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (with-temp-buffer
      (org-mode)
      (evil-local-mode 1)
      (evil-normal-state)
      (insert "old text")
      (evil-visual-select (point-min) (point-max) 'char)
      (evil-paste-after 1)
      (should (equal (buffer-string) org-html-paste-test-org)))))

(ert-deftest org-html-paste-conversion-failure-falls-back ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (let ((my-org-html-paste-pandoc "/nonexistent/pandoc"))
      (with-temp-buffer
        (org-mode)
        (org-yank)
        (should (equal (buffer-string) org-html-paste-test-plain))))))

(ert-deftest org-html-paste-undo-restores-buffer ()
  (org-html-paste-test-with-clipboard
      org-html-paste-test-plain org-html-paste-test-html
    (with-temp-buffer
      (org-mode)
      (buffer-enable-undo)
      (insert "before ")
      (undo-boundary)
      (org-yank)
      (undo-boundary)
      (undo-only 1)
      (should (equal (buffer-string) "before ")))))

(ert-deftest org-html-paste-preserves-lists-and-trailing-newline-without-bold ()
  (org-html-paste-test-with-clipboard
      "Docs\n" "<ul><li><strong>Docs</strong>: <a href=\"https://example.com\">link</a></li></ul>"
    (with-temp-buffer
      (org-mode)
      (org-yank)
      (should (equal (buffer-string) "- Docs: [[https://example.com][link]]\n")))))

(ert-deftest org-html-paste-unstyled-branch-links ()
  (dolist (command '(org-yank evil-paste-after))
    (org-html-paste-test-with-clipboard
        "Example: branch_name=a*b"
        "<p><strong>Example:</strong> <a href=\"https://example.com/branch?x=a=b\"><em><code>branch_name=a*b</code></em></a></p>"
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (call-interactively command)
        (should (equal (buffer-string)
                       "Example: [[https://example.com/branch?x=a=b][branch_name=a*b]]"))))))

(ert-deftest org-html-paste-strips-inline-styles ()
  (should
   (equal
    (my-org-html-paste--convert
     "<p><b>bold</b> <i>italic</i> <u>underline</u> <s>strike</s> <code>code</code> H<sub>2</sub>O x<sup>2</sup></p>"
     "bold italic underline strike code H2O x2")
    "bold italic underline strike code H2O x2")))

(ert-deftest org-html-paste-html-breaks-use-plain-newlines ()
  (dolist (command '(org-yank evil-paste-after evil-paste-before))
    (org-html-paste-test-with-clipboard
        "Read first.\nSecond line.\n\nRead second.\n\nLast paragraph."
        (concat "<div>Read <a href=\"https://example.com/one\">first</a>."
                "<br>Second line.<br><br>Read "
                "<a href=\"https://example.com/two\">second</a>."
                "<br><br>Last paragraph.</div>")
      (with-temp-buffer
        (org-mode)
        (evil-local-mode 1)
        (evil-normal-state)
        (call-interactively command)
        (should (equal (buffer-string)
                       (concat "Read [[https://example.com/one][first]].\nSecond line.\n\n"
                               "Read [[https://example.com/two][second]].\n\nLast paragraph.")))))))

(ert-deftest org-html-paste-rtf-line-breaks-use-plain-newlines ()
  (skip-unless (eq system-type 'darwin))
  (should (equal (my-org-html-paste--convert
                  (concat "{\\rtf1\\ansi First line.\\line Second line.\\line\\line "
                          "{\\field{\\*\\fldinst{HYPERLINK \"https://example.com\"}}"
                          "{\\fldrslt{Last paragraph}}}.}")
                  "First line.\nSecond line.\n\nLast paragraph." 'rtf)
                 "First line.\nSecond line.\n\n[[https://example.com][Last paragraph]].")))

(ert-deftest org-html-paste-break-cleanup-preserves-literal-backslashes ()
  (should (equal (my-org-html-paste--convert
                  "<p>Path C:\\example\\file<br>Pattern \\d+</p>"
                  "Path C:\\example\\file\nPattern \\d+")
                 "Path C:\\example\\file\nPattern \\d+")))

(ert-deftest org-html-paste-image-width-remains-an-org-attribute ()
  (should (equal (my-org-html-paste--convert
                  "<div>#+ATTR_ORG: :width 120<br>[[file:images/example.png]]<br></div>"
                  "#+ATTR_ORG: :width 120\n[[file:images/example.png]]\n")
                 "#+ATTR_ORG: :width 120\n[[file:images/example.png]]\n")))

;;; org-html-paste-test.el ends here
