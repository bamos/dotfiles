(require 'org)
(require 'htmlize)

; (add-to-list 'load-path "~/repos/ox-ipynb")
; (require 'ox-ipynb)

(add-hook 'org-mode-hook (lambda ()
  ;; Dvorak.
  (local-set-key "\M-h" 'org-do-promote)
  (local-set-key "\M-s" 'org-do-demote)
  (local-set-key (kbd "M-S-h") 'org-promote-subtree)
  (local-set-key (kbd "M-S-s") 'org-demote-subtree)

  (local-set-key "\M-t" 'org-metadown)
  (local-set-key "\M-n" 'org-metaup)

  (local-set-key (kbd "C-S-<return>") 'org-insert-heading-after-current)

  (setq indent-tabs-mode nil)
  (setq tap-width 2)
  (setq evil-shift-width 2)
))

(global-set-key (kbd "C-c a") 'org-agenda)
;; (global-set-key (kbd "C-c c") 'org-capture)

;; Override org sparse tree binding for date insertion.
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c /") 'insert-current-date-ymd))

(setq org-startup-with-inline-images t
      org-startup-folded nil
      org-src-fontify-natively t
      org-latex-to-pdf-process (list "latexmk -pdf %f")
      org-image-actual-width 600
      org-agenda-skip-scheduled-if-done t
      org-agenda-files '("~/org")
      ; org-agenda-files '("~/Library/CloudStorage/OneDrive-Personal/org")
      org-capture-templates '())

; (org-babel-do-load-languages
;  'org-babel-load-languages
; '((sh . t)
;   (python . t)))
;(setq org-confirm-babel-evaluate nil)
;(setq org-babel-python-command "python3")

;; Automatic link description downloading.
;; Source: https://github.com/pkkm/.emacs.d/blob/8ac745bae09e303a13708fb9260849de9e1d8502/conf/mode-specific/org.el#L90

; (use-package s :ensure t :commands s-trim s-collapse-whitespace)
;; (autoload 'mm-url-decode-entities-string "mm-url")
;; (defun get-url-html-title (url &rest ignored)
;; "Return the title of the HTML page at URL."
;; (let ((download-buffer (url-retrieve-synchronously url))
;;         title-start title-end)
;;     (save-excursion
;;     (set-buffer download-buffer)
;;     (beginning-of-buffer)
;;     (setq title-start (search-forward "<title>"))
;;     (search-forward "</title>")
;;     (setq title-end (search-backward "<"))
;;     (s-trim
;;         (s-collapse-whitespace
;;         (mm-url-decode-entities-string
;;         (buffer-substring-no-properties title-start title-end)))))))


;; https://github.com/jmn/dotfiles/blob/c84bba70fbcf52126b4d9b34e2794b73327048b3/tag-emacs/emacs.d/config-jmn-functions.el
(defun url-get-title (url &optional descr)
  "Takes a URL and returns the value of the <title> HTML tag,
   Thanks to https://frozenlock.org/tag/url-retrieve/ for documenting url-retrieve
   customize org-make-link-description-function."
  ;; Skip URLs that are known to require authentication
  (if (or (string-match-p "docs\\.google\\.com" url)
          (string-match-p "slack\\.com" url)
          (string-match-p "accounts\\.google\\.com" url))
      nil
    (condition-case nil
        (let ((buffer (url-retrieve-synchronously url t nil 5))
              (title nil))
          (when buffer
            (save-excursion
              (set-buffer buffer)
              (goto-char (point-min))
              (when (search-forward-regexp "<title>\\([^<]+?\\)</title>" nil t)
                (setq title (match-string 1)))
              (kill-buffer (current-buffer)))
            title))
      (error nil))))

(defun my-org-toggle-auto-link-description ()
"Toggle automatically downloading link descriptions."
(interactive)
(if org-make-link-description-function
    (progn
        (setq org-make-link-description-function nil)
        (message "Automatic link description downloading disabled."))
  (setq org-make-link-description-function (quote url-get-title))
  (message "Automatic link description downloading enabled.")))

;; Source: http://stackoverflow.com/a/27043756
(defun my-org-archive-done-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (outline-previous-heading)))
   "/DONE" 'file))


;;; TODO: Clean all of this up at some point.

(defun org-export-deterministic-reference (references) 0)
    ;; (let ((new 0))
       ;; (while (rassq new references) (setq new (+ new 1)))
       ;; new))
(advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)
;; (advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)


;;; From https://github.com/bryal/.emacs.d/blob/c5ee3d62a47a08c1f8da9e27584d42e5089aa21d/lisp/custom-org-html.el
(require 'ox-html)


(defun headline? (datum)
  (eq (car datum) 'headline))

(defun get-raw-value (datum)
  (plist-get (cadr datum) :raw-value))

(defun custom-org-export-get-reference (datum info)
  "Return a unique reference for DATUM, as a string.

DATUM is either an element or an object.  INFO is the current
export state, as a plist.

This function checks `:crossrefs' property in INFO for search
cells matching DATUM before creating a new reference.  Returned
reference consists of alphanumeric characters only."
  (let ((cache (plist-get info :internal-references)))
    (or (car (rassq datum cache))
	(let* ((crossrefs (plist-get info :crossrefs))
	       (cells (org-export-search-cells datum))
	       ;; Preserve any pre-existing association between
	       ;; a search cell and a reference, i.e., when some
	       ;; previously published document referenced a location
	       ;; within current file (see
	       ;; `org-publish-resolve-external-link').
	       ;;
	       ;; However, there is no guarantee that search cells are
	       ;; unique, e.g., there might be duplicate custom ID or
	       ;; two headings with the same title in the file.
	       ;;
	       ;; As a consequence, before re-using any reference to
	       ;; an element or object, we check that it doesn't refer
	       ;; to a previous element or object.
	       (new (or (cl-some
			 (lambda (cell)
			   (let ((stored (cdr (assoc cell crossrefs))))
			     (when stored
			       (let ((old (org-export-format-reference stored)))
				 (and (not (assoc old cache)) stored)))))
			 cells)
			(org-export-new-reference cache)))
               (new-ref (org-export-format-reference new))
               (reference-string
                (if (headline? datum)
                    (concat (replace-regexp-in-string " " "-" (get-raw-value datum))
                            "-" new-ref)
                             new-ref)
                ))
	  ;; Cache contains both data already associated to
	  ;; a reference and in-use internal references, so as to make
	  ;; unique references.
	  (dolist (cell cells) (push (cons cell new) cache))
	  ;; Retain a direct association between reference string and
	  ;; DATUM since (1) not every object or element can be given
	  ;; a search cell (2) it permits quick lookup.
	  (push (cons reference-string datum) cache)
	  (plist-put info :internal-references cache)
	  reference-string))))

(advice-add #'org-export-get-reference :override #'custom-org-export-get-reference)

; https://christiantietze.de/posts/2019/03/sync-emacs-org-files/
(add-hook 'auto-save-hook 'org-save-all-org-buffers)

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
