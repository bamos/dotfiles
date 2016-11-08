; Reference: https://github.com/thierryvolpiatto/emacs-tv-config/blob/master/init-helm-thierry.el

(require 'helm-mode)
(require 'helm-config)
(require 'helm-adaptive)
(require 'helm-ring)
(require 'helm-utils)
(require 'helm-sys)
(require 'helm-descbinds)

(helm-mode 0)
(helm-adaptive-mode 1)
(helm-push-mark-mode 1)
(helm-popup-tip-mode 1)
(helm-top-poll-mode 1)


;;;; Test Sources or new helm code.
;;   !!!WARNING EXPERIMENTAL!!!

(defun helm/version-1 ()
  (with-temp-buffer
    (insert-file-contents (find-library-name "helm-core-pkg"))
    (goto-char (point-min))
    (when (re-search-forward
           "\\([0-9]+?\\)\\.?\\([0-9]*\\)\\.?\\([0-9]*\\)\\.?[0-9]*" nil t)
      (match-string-no-properties 0))))

;; Helm version: 1.9.3
(defun helm/version (arg)
  (interactive "P")
  (let ((version-str (format "Helm version: %s" (helm/version-1))))
    (if arg (insert version-str) (message version-str))))

(defun helm/git-version ()
  (shell-command-to-string
   "git log --pretty='format:%H' -1"))

(defun helm/turn-on-header-line ()
  (interactive)
  (setq helm-echo-input-in-header-line t)
  (setq helm-split-window-in-side-p t)
  (helm-autoresize-mode -1)
  (add-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe)
  )

(defun helm/turn-off-header-line ()
  (interactive)
  (setq helm-echo-input-in-header-line nil)
  ;;(helm-autoresize-mode 1)
  (setq helm-split-window-in-side-p nil)
  (remove-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe)
  )

(defun helm/occur-which-func ()
  (interactive)
  (with-current-buffer
      (or (helm-aif (with-helm-buffer
                      (window-buffer helm-persistent-action-display-window))
              (and (null (minibufferp it)) it))
          helm-current-buffer)
    (when (eq major-mode 'emacs-lisp-mode)
      (message "[%s]" (which-function)))))

(define-key helm-moccur-map (kbd "C-M-a") 'helm/occur-which-func)
(define-key helm-grep-map   (kbd "C-M-a") 'helm/occur-which-func)

;; Show the visibles buffers on top of list (issue #1301)

(defun helm/modify-ido-temp-list ()
  (let ((bl (mapcar #'buffer-name (buffer-list (selected-frame)))))
    (setq ido-temp-list (nconc (cdr bl) (list (car bl))))))
;;(add-hook 'ido-make-buffer-list-hook 'helm/modify-ido-temp-list)


;;; Helm-command-map
;;
;;
(define-key helm-command-map (kbd "g") 'helm-apt)
(define-key helm-command-map (kbd "z") 'helm-complex-command-history)
(define-key helm-command-map (kbd "w") 'helm-w3m-bookmarks)
(define-key helm-command-map (kbd "x") 'helm-firefox-bookmarks)
(define-key helm-command-map (kbd "#") 'helm-emms)
(define-key helm-command-map (kbd "I") 'helm-imenu-in-all-buffers)

;;; Global-map
;;
;;
(global-set-key (kbd "M-x")                          'undefined)
(global-set-key (kbd "M-x")                          'helm-M-x)
(global-set-key (kbd "M-y")                          'helm-show-kill-ring)
(global-set-key (kbd "C-x C-f")                      'helm-find-files)
(global-set-key (kbd "C-c <SPC>")                    'helm-all-mark-rings)
(global-set-key (kbd "C-x r b")                      'helm-filtered-bookmarks)
(global-set-key (kbd "C-h r")                        'helm-info-emacs)
(global-set-key (kbd "C-:")                          'helm-eval-expression-with-eldoc)
(global-set-key (kbd "C-,")                          'helm-calcul-expression)
(global-set-key (kbd "C-h d")                        'helm-info-at-point)
(global-set-key (kbd "C-h i")                        'helm-info)
(global-set-key (kbd "C-x C-d")                      'helm-browse-project)
(global-set-key (kbd "<f1>")                         'helm-resume)
(global-set-key (kbd "C-h C-f")                      'helm-apropos)
(global-set-key (kbd "C-h a")                        'helm-apropos)
(global-set-key (kbd "<f5> s")                       'helm-find)
(global-set-key (kbd "<f2>")                         'helm-execute-kmacro)
(global-set-key (kbd "C-c i")                        'helm-imenu-in-all-buffers)
; (global-set-key (kbd "<f11> o")                      'helm-org-agenda-files-headings)
(global-set-key (kbd "C-s")                          'helm-occur)
(define-key global-map [remap jump-to-register]      'helm-register)
(define-key global-map [remap list-buffers]          'helm-mini)
(define-key global-map [remap dabbrev-expand]        'helm-dabbrev)
(define-key global-map [remap find-tag]              'helm-etags-select)
(define-key global-map [remap xref-find-definitions] 'helm-etags-select)
(define-key global-map (kbd "M-g a")                 'helm-do-grep-ag)
(define-key global-map (kbd "M-g g")                 'helm-grep-do-git-grep)
(define-key global-map (kbd "M-g i")                 'helm-gid)
(define-key global-map (kbd "C-x r p")               'helm-projects-history)

(helm-multi-key-defun helm-multi-lisp-complete-at-point
    "Multi key function for completion in emacs lisp buffers.
First call indent, second complete symbol, third complete fname."
  '(helm-lisp-indent
    helm-lisp-completion-at-point
    helm-complete-file-name-at-point)
  0.3)

(if (and (boundp 'tab-always-indent)
         (eq tab-always-indent 'complete)
         (boundp 'completion-in-region-function))
    (progn
      (define-key lisp-interaction-mode-map [remap indent-for-tab-command] 'helm-multi-lisp-complete-at-point)
      (define-key emacs-lisp-mode-map       [remap indent-for-tab-command] 'helm-multi-lisp-complete-at-point)

      ;; lisp complete. (Rebind M-<tab>)
      (define-key lisp-interaction-mode-map [remap completion-at-point] 'helm-lisp-completion-at-point)
      (define-key emacs-lisp-mode-map       [remap completion-at-point] 'helm-lisp-completion-at-point))

    (define-key lisp-interaction-mode-map [remap indent-for-tab-command] 'helm-multi-lisp-complete-at-point)
    (define-key emacs-lisp-mode-map       [remap indent-for-tab-command] 'helm-multi-lisp-complete-at-point)

    ;; lisp complete. (Rebind M-<tab>)
    (define-key lisp-interaction-mode-map [remap completion-at-point] 'helm-lisp-completion-at-point)
    (define-key emacs-lisp-mode-map       [remap completion-at-point] 'helm-lisp-completion-at-point))

(unless (boundp 'completion-in-region-function)
  (add-hook 'ielm-mode-hook
            #'(lambda ()
                (define-key ielm-map [remap completion-at-point] 'helm-lisp-completion-at-point))))

;;; helm find files
;;
(define-key helm-find-files-map (kbd "C-d") 'helm-ff-persistent-delete)
(define-key helm-buffer-map (kbd "C-d")     'helm-buffer-run-kill-persistent)
(define-key helm-find-files-map (kbd "C-/") 'helm-ff-run-find-sh-command)


;;; Describe key-bindings
;;
;;
(helm-descbinds-mode 1)            ; C-h b, C-x C-h


;;; Helm-variables
;;
;;
(setq helm-net-prefer-curl                            nil
      helm-kill-ring-threshold                        1
      helm-raise-command                              "wmctrl -xa %s"
      helm-scroll-amount                              4
      helm-idle-delay                                 0.01
      helm-input-idle-delay                           0.01
      helm-default-external-file-browser              "thunar"
      helm-pdfgrep-default-read-command               "evince --page-label=%p '%f'"
      helm-ff-auto-update-initial-value               t
      helm-grep-default-command                       "ack-grep -Hn --color --smart-case --no-group %e %p %f"
      helm-grep-default-recurse-command               "ack-grep -H --color --smart-case --no-group %e %p %f"
      helm-reuse-last-window-split-state              t
      helm-always-two-windows                         t
      helm-split-window-in-side-p                     nil
      helm-show-action-window-other-window            'left
      helm-buffers-favorite-modes                     (append helm-buffers-favorite-modes '(picture-mode artist-mode))
      helm-ls-git-status-command                      'magit-status-internal
      helm-M-x-requires-pattern                       0
      helm-dabbrev-cycle-threshold                    5
      helm-surfraw-duckduckgo-url                     "https://duckduckgo.com/?q=%s&ke=-1&kf=fw&kl=fr-fr&kr=b&k1=-1&k4=-1"
      helm-google-suggest-search-url                  helm-surfraw-duckduckgo-url
      helm-boring-file-regexp-list
      '("\\.git" "\\.hg" "\\.svn" "\\.CVS" "\\._darcs" "\\.la$" "\\.o$" "\\.i$" "\\.steam" "\\undo-tree-history")
      helm-buffer-skip-remote-checking                t
      helm-apropos-fuzzy-match                        t
      helm-M-x-fuzzy-match                            t
      helm-lisp-fuzzy-completion                      t
      helm-completion-in-region-fuzzy-match           t
      helm-buffers-fuzzy-matching                     t
      helm-move-to-line-cycle-in-source               t
      ido-use-virtual-buffers                         t             ; Needed in helm-buffers-list
      helm-tramp-verbose                              6
      helm-locate-command                             "locate %s -e -A --regex %s"
      helm-org-headings-fontify                       t
      helm-autoresize-max-height                      80 ; it is %.
      helm-autoresize-min-height                      20 ; it is %.
      fit-window-to-buffer-horizontally               1
      helm-open-github-closed-issue-since             7
      helm-highlight-matches-around-point-max-lines   30
      helm-search-suggest-action-wikipedia-url
      "https://fr.wikipedia.org/wiki/Special:Search?search=%s"
      helm-wikipedia-suggest-url
      "https://fr.wikipedia.org/w/api.php?action=opensearch&search="
      helm-wikipedia-summary-url
      "https://fr.wikipedia.org/w/api.php?action=parse&format=json&prop=text&section=0&page="
      helm-firefox-show-structure nil
      helm-turn-on-recentf nil
      helm-mini-default-sources '(helm-source-buffers-list helm-source-buffer-not-found)
      helm-debug-root-directory "/home/thierry/tmp/helm-debug"
      helm-follow-mode-persistent t
      )

;; Avoid hitting forbidden directory .gvfs when using find.
(add-to-list 'completion-ignored-extensions ".gvfs/")


;;; Toggle grep program
;;
;;
(defun helm/eselect-grep ()
  (interactive)
  (when (y-or-n-p (format "Current grep program is %s, switching? "
                          (helm-grep-command)))
    (if (helm-grep-use-ack-p)
        (setq helm-grep-default-command
              "grep --color=always -d skip %e -n%cH -e %p %f"
              helm-grep-default-recurse-command
              "grep --color=always -d recurse %e -n%cH -e %p %f")
        (setq helm-grep-default-command
              "ack-grep -Hn --color --smart-case --no-group %e %p %f"
              helm-grep-default-recurse-command
              "ack-grep -H --color --smart-case --no-group %e %p %f"))
    (message "Switched to %s" (helm-grep-command))))

;;; Debugging
;;
;;
(defun helm/debug-toggle ()
  (interactive)
  (setq helm-debug (not helm-debug))
  (message "Helm Debug is now %s"
           (if helm-debug "Enabled" "Disabled")))

(defun helm/ff-candidates-lisp-p (candidate)
  (cl-loop for cand in (helm-marked-candidates)
           always (string-match "\.el$" cand)))


;;; Modify source attributes
;;
;; Add actions to `helm-source-find-files' IF:
(defmethod helm-setup-user-source ((source helm-source-ffiles))
  (helm-source-add-action-to-source-if
   "Byte compile file(s) async"
   'tv/async-byte-compile-file
   source
   'helm/ff-candidates-lisp-p)
  (helm-source-add-action-to-source-if
   "Byte recompile directory"
   'async-byte-recompile-directory
   source
   'file-directory-p))

(defmethod helm-setup-user-source ((source helm-source-buffers))
  (setf (slot-value source 'candidate-number-limit) 300))


;;; helm dictionary
;;
(setq helm-dictionary-database "~/helm-dictionary/dic-en-fr.iso")
(setq helm-dictionary-online-dicts '(("translate.reference.com en->fr" .
                                      "http://translate.reference.com/translate?query=%s&src=en&dst=fr")
                                     ("translate.reference.com fr->en" .
                                      "http://translate.reference.com/translate?query=%s&src=fr&dst=en")))


(provide 'init-helm-thierry)

;;; init-helm-thierry.el ends here
