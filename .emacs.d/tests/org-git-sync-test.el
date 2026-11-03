;;; org-git-sync-test.el --- Real Git sync regressions -*- lexical-binding: t; -*-

;; Run from .dotfiles:
;; emacs --batch -Q -l .emacs.d/tests/org-git-sync-test.el -f ert-run-tests-batch-and-exit
(require 'ert)
(load (expand-file-name "../org-git-sync.el"
                        (file-name-directory load-file-name)))
(cancel-timer my-org-git-timer)

(defun org-sync-test-git (directory &rest args)
  "Run Git ARGS in DIRECTORY, failing with its output on error."
  (let ((default-directory directory))
    (with-temp-buffer
      (let ((status (apply #'call-process "git" nil t nil args)))
        (unless (equal status 0)
          (ert-fail (list args status (buffer-string))))
        (string-trim (buffer-string))))))

(defun org-sync-test-wait ()
  "Wait for operations and their sentinels, with a bounded failure timeout."
  (let ((deadline (+ (float-time) 15)))
    (while (and (> (hash-table-count my-org-git-processes) 0)
                (< (float-time) deadline))
      (accept-process-output nil 0.05))
    (should (= 0 (hash-table-count my-org-git-processes)))))

(defmacro org-sync-test-with-repo (&rest body)
  "Run BODY with independent local ROOT, PEER and REMOTE repositories."
  (declare (indent 0))
  `(let* ((directory (make-temp-file "org-sync-test-" t))
          (root (concat directory "/notes/"))
          (peer (concat directory "/peer/"))
          (remote (concat directory "/remote.git"))
          (process-environment (copy-sequence process-environment))
          (my-org-git-processes (make-hash-table :test 'equal))
          (my-org-git-pending-files (make-hash-table :test 'equal))
          (my-org-last-pull-times (make-hash-table :test 'equal))
          (window-buffer-change-functions nil)
          (make-backup-files nil)
          (auto-save-default nil))
     ;; Avoid inheriting signing, hooks, identities, or remotes from dotfiles.
     (setenv "GIT_CONFIG_GLOBAL" "/dev/null")
     (setenv "GIT_CONFIG_NOSYSTEM" "1")
     (setenv "GIT_AUTHOR_NAME" "Sync test")
     (setenv "GIT_AUTHOR_EMAIL" "test@example.invalid")
     (setenv "GIT_COMMITTER_NAME" "Sync test")
     (setenv "GIT_COMMITTER_EMAIL" "test@example.invalid")
     (unwind-protect
         (progn
           (org-sync-test-git directory "init" "--bare" "--initial-branch=main" remote)
           (org-sync-test-git directory "clone" remote root)
           (with-temp-file (concat root "notes.org") (insert "* Initial note\n"))
           (org-sync-test-git root "add" "notes.org")
           (org-sync-test-git root "commit" "-m" "Initial")
           (org-sync-test-git root "push" "-u" "origin" "main")
           (org-sync-test-git directory "clone" remote peer)
           (with-current-buffer (find-file-noselect (concat root "notes.org"))
             ,@body))
       (maphash (lambda (_root process)
                  (set-process-sentinel process #'ignore)
                  (when (process-live-p process) (delete-process process)))
                my-org-git-processes)
       (dolist (buffer (buffer-list))
         (with-current-buffer buffer
           (when (or (and buffer-file-name
                          (string-prefix-p directory buffer-file-name))
                     (string-prefix-p (concat "*Org Git: " directory) (buffer-name)))
             (set-buffer-modified-p nil)
             (kill-buffer buffer))))
       (delete-directory directory t))))

(defun org-sync-test-publish (peer text)
  "Publish TEXT from the other local clone PEER."
  (with-temp-file (concat peer "notes.org") (insert text))
  (org-sync-test-git peer "commit" "-am" "Remote edit")
  (org-sync-test-git peer "push"))

(ert-deftest org-sync-typing-survives-pull ()
  (org-sync-test-with-repo
    (my-org-pull-on-buffer-switch)
    ;; Sentinels cannot run until Emacs yields: type after starting Git but
    ;; before its completion callback, without a timing-dependent sleep.
    (goto-char (point-max))
    (insert "Typing during pull\n")
    (org-sync-test-wait)
    (should (buffer-modified-p))
    (should (equal (buffer-string) "* Initial note\nTyping during pull\n"))))

(ert-deftest org-sync-no-change-does-not-reload ()
  (org-sync-test-with-repo
    (goto-char 5)
    (let ((tick (buffer-chars-modified-tick)))
      (my-org-pull-on-buffer-switch)
      (org-sync-test-wait)
      (should (= tick (buffer-chars-modified-tick)))
      (should (= 5 (point))))))

(ert-deftest org-sync-background-refreshes-clean-buffer ()
  (org-sync-test-with-repo
    (org-sync-test-publish peer "* Remote update\n")
    (goto-char 5)
    (my-org-git-background-pull)
    (org-sync-test-wait)
    (should (equal (buffer-string) "* Remote update\n"))
    (should (= 5 (point)))
    (should-not (buffer-modified-p))))

(ert-deftest org-sync-remote-change-preserves-typing-and-blocks-save ()
  (org-sync-test-with-repo
    (org-sync-test-publish peer "* Remote update\n")
    (my-org-pull-on-buffer-switch)
    (goto-char (point-max))
    (insert "Unsaved work\n")
    (org-sync-test-wait)
    (should (equal (buffer-string) "* Initial note\nUnsaved work\n"))
    (should (buffer-modified-p))
    (should-error (run-hooks 'before-save-hook) :type 'user-error)
    (should (equal (with-temp-buffer
                     (insert-file-contents (concat root "notes.org"))
                     (buffer-string))
                   "* Remote update\n"))))

(ert-deftest org-sync-save-during-pull-is-queued-and-pushed ()
  (org-sync-test-with-repo
    (my-org-pull-on-buffer-switch)
    (let ((process (gethash root my-org-git-processes)))
      (goto-char (point-max))
      (insert "Saved work\n")
      (save-buffer)
      (should (eq process (gethash root my-org-git-processes)))
      (should (equal (gethash root my-org-git-pending-files) '("notes.org"))))
    (org-sync-test-wait)
    (should (equal (org-sync-test-git remote "show" "main:notes.org")
                   "* Initial note\nSaved work"))
    (should-not (gethash root my-org-git-pending-files))))

(ert-deftest org-sync-quotes-filenames-and-leaves-unrelated-staging ()
  (org-sync-test-with-repo
    (with-temp-file (concat root "unrelated.txt") (insert "Leave staged\n"))
    (org-sync-test-git root "add" "unrelated.txt")
    (with-current-buffer (find-file-noselect (concat root "notes with 'quotes'.org"))
      (insert "* Quoted filename\n")
      (save-buffer)
      (org-sync-test-wait))
    (should (equal (org-sync-test-git remote "show" "main:notes with 'quotes'.org")
                   "* Quoted filename"))
    (should (equal (org-sync-test-git root "diff" "--cached" "--name-only")
                   "unrelated.txt"))))
