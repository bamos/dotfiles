;;; org-git-sync.el --- Background Git sync for Org files -*- lexical-binding: t; -*-

(require 'org)
(require 'seq)

;; Keep Git operations serialized per repository, including saves during a pull.
(defvar my-org-git-processes (make-hash-table :test 'equal))
(defvar my-org-git-pending-files (make-hash-table :test 'equal))
(defvar my-org-last-pull-times (make-hash-table :test 'equal))
(defvar my-org-git-timer nil)

(defun my-org-git-root ()
  "Return the current Org file's repository, resolving symlinks."
  (when (and (derived-mode-p 'org-mode) buffer-file-name
             (not (file-remote-p buffer-file-name)))
    (locate-dominating-file (file-truename buffer-file-name) ".git")))

(defun my-org-git-buffers (root)
  "Return open Org buffers belonging to ROOT."
  (let (buffers)
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal root (my-org-git-root))
          (push buffer buffers))))
    buffers))

(defun my-org-git-refresh (root)
  "Refresh changed files in ROOT without discarding unsaved edits."
  (dolist (buffer (my-org-git-buffers root))
    (with-current-buffer buffer
      (unless (verify-visited-file-modtime buffer)
        (if (buffer-modified-p)
            (message "Org sync: remote changes in %s; keeping your unsaved edits"
                     (buffer-name))
          (let ((position (point))
                (windows (mapcar (lambda (window)
                                   (list window (window-start window)
                                         (window-point window)))
                                 (get-buffer-window-list buffer nil t))))
            (revert-buffer t t t)
            (goto-char (min position (point-max)))
            (dolist (state windows)
              (when (window-live-p (car state))
                (set-window-start (car state) (nth 1 state) t)
                (set-window-point (car state)
                                  (min (nth 2 state) (point-max)))))))))))

(defun my-org-git-finished (process _event)
  "Refresh buffers and service queued saves after PROCESS finishes."
  (when (memq (process-status process) '(exit signal))
    (let ((root (process-get process 'org-root)))
      (remhash root my-org-git-processes)
      (if (= 0 (process-exit-status process))
          (progn
            (my-org-git-refresh root)
            (my-org-git-start root))
        ;; Keep failed and pending saves for a later attempt, without a retry loop.
        (puthash root
                 (delete-dups (append (process-get process 'org-files)
                                      (gethash root my-org-git-pending-files)))
                 my-org-git-pending-files)
        (message "Org Git sync failed; see %s" (buffer-name (process-buffer process)))))))

(defun my-org-git-start (root &optional pull)
  "Sync queued saved files in ROOT, or PULL if no saves are pending."
  (unless (gethash root my-org-git-processes)
    (let* ((files (gethash root my-org-git-pending-files))
           (dirty (seq-some (lambda (buffer)
                              (buffer-modified-p buffer))
                            (my-org-git-buffers root)))
           (do-pull (and pull (not dirty)))
           (default-directory root))
      (when (or files do-pull)
        (let* ((paths (mapconcat #'shell-quote-argument files " "))
               ;; Commit saved changes before pulling, so rebase can merge them.
               ;; --only avoids committing unrelated staged changes.
               (script (if files
                           (format "git add -- %s && (git diff --cached --quiet -- %s || git commit --only -m %s -- %s) && git pull --rebase --autostash && git push"
                                   paths paths
                                   (shell-quote-argument
                                    (format-time-string "Auto-sync: %Y-%m-%d %H:%M:%S"))
                                   paths)
                         "git pull --rebase --autostash"))
               (process (start-process-shell-command
                         "org-git-sync"
                         (get-buffer-create (format "*Org Git: %s*" root))
                         script)))
          (remhash root my-org-git-pending-files)
          (puthash root (float-time) my-org-last-pull-times)
          (puthash root process my-org-git-processes)
          (process-put process 'org-root root)
          (process-put process 'org-files files)
          (set-process-query-on-exit-flag process nil)
          (set-process-sentinel process #'my-org-git-finished))))))

(defun my-org-auto-git-sync ()
  "Queue the saved Org file for automatic commit, pull, and push."
  (interactive)
  (let ((root (my-org-git-root)))
    (when root
      (let ((file (file-relative-name (file-truename buffer-file-name) root)))
        (puthash root (cons file (delete file (gethash root my-org-git-pending-files)))
                 my-org-git-pending-files))
      (my-org-git-start root))))

(defun my-org-pull-on-buffer-switch ()
  "Refresh safely and request a pull at most once a minute per repository."
  (let ((root (my-org-git-root)))
    (when root
      (my-org-git-refresh root)
      (when (> (- (float-time) (gethash root my-org-last-pull-times 0)) 60)
        (my-org-git-start root t)))))

(defun my-org-git-background-pull ()
  "Keep repositories of open Org buffers up to date in the background."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (my-org-pull-on-buffer-switch))))

(defun my-org-git-check-before-save ()
  "Prevent auto-save from overwriting remote changes under unsaved edits."
  (when (and (my-org-git-root) (buffer-modified-p)
             (not (verify-visited-file-modtime (current-buffer))))
    (user-error "Org file changed on disk; reconcile with M-x diff-buffer-with-file before saving")))

(defun my-org-git-setup ()
  "Enable automatic Git sync for this Org buffer."
  (add-hook 'before-save-hook #'my-org-git-check-before-save nil t)
  (add-hook 'after-save-hook #'my-org-auto-git-sync nil t))

(add-hook 'org-mode-hook #'my-org-git-setup)
(add-hook 'window-buffer-change-functions
          (lambda (_) (my-org-pull-on-buffer-switch)))

(when (timerp my-org-git-timer)
  (cancel-timer my-org-git-timer))
(setq my-org-git-timer (run-with-timer 5 60 #'my-org-git-background-pull))

(provide 'org-git-sync)
