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

;; Helper function to run git commands for org files
(defun my-org-run-git-command (script process-name on-success-fn)
  "Run a git SCRIPT for current buffer file if in git repo.
PROCESS-NAME is the name for the background process.
ON-SUCCESS-FN is called with filename and real-path when git command succeeds."
  (when (buffer-file-name)
    (let* ((file-path (buffer-file-name))
           (real-path (file-truename file-path))
           (default-directory (file-name-directory real-path))
           (filename (file-name-nondirectory real-path))
           (in-git-repo (locate-dominating-file default-directory ".git")))
      (when in-git-repo
        (condition-case err
            (let ((proc (start-process-shell-command process-name nil script)))
              (set-process-sentinel
               proc
               `(lambda (process event)
                  (when (memq (process-status process) '(exit signal))
                    (if (= 0 (process-exit-status process))
                        (funcall ,on-success-fn ,filename ,real-path)
                      (message "%s failed for %s (exit code %d)"
                               ,process-name ,filename (process-exit-status process)))))))
          (error
           (message "%s failed: %s" process-name (error-message-string err))))))))

;; Track last pull time per buffer to avoid too frequent pulls
(defvar my-org-last-pull-times (make-hash-table :test 'equal)
  "Hash table tracking last pull time for each file path.")

;; Pull updates when switching to an org buffer
(defun my-org-pull-on-buffer-switch ()
  "Pull git updates when switching to an org-mode buffer.
Only pulls once every 60 seconds per file to avoid excessive network calls."
  (when (and (eq major-mode 'org-mode)
             (buffer-file-name))
    (let* ((real-path (file-truename (buffer-file-name)))
           (last-pull (gethash real-path my-org-last-pull-times 0))
           (time-since-pull (- (float-time) last-pull)))
      ;; Only pull if haven't pulled in last 60 seconds
      (when (> time-since-pull 60)
        (puthash real-path (float-time) my-org-last-pull-times)
        (message "Pulling updates for %s..." (file-name-nondirectory real-path))
        (my-org-run-git-command
         "git fetch && git pull --rebase --autostash"
         "org-git-pull"
         (lambda (filename real-path)
           (message "Git pull successful: %s" filename)
           ;; Revert buffer if file changed on disk
           (when (get-file-buffer real-path)
             (with-current-buffer (get-file-buffer real-path)
               (revert-buffer t t t)))))))))

;; Auto-sync org file to git on save (with pull/push)
(defun my-org-auto-git-sync ()
  "Automatically commit and push org files that are in git repositories.
Handles remote changes by pulling before pushing."
  (interactive)
  (when (buffer-file-name)
    (let* ((filename (file-name-nondirectory (file-truename (buffer-file-name))))
           (sync-script (format "git fetch && \
git pull --rebase --autostash && \
git add %s && \
(git diff --cached --quiet || git commit -m 'Auto-sync: %s') && \
git push"
                                filename
                                (format-time-string "%Y-%m-%d %H:%M:%S"))))
      (message "Syncing %s to git..." filename)
      (my-org-run-git-command
       sync-script
       "org-git-sync"
       (lambda (filename _real-path)
         (message "Git sync successful: %s" filename))))))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'my-org-auto-git-sync nil t)))

(add-hook 'window-buffer-change-functions
          (lambda (_) (my-org-pull-on-buffer-switch)))
