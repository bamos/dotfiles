(defconst user-init-dir (cond
  ((boundp 'user-emacs-directory) user-emacs-directory)
  ((boundp 'user-init-directory) user-init-directory)
  (t "~/.emacs.d/")))

(defun load-user-file (file) (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(load-user-file "packages.el")
(load-user-file "clipboard.el")
(load-user-file "mail.el")
(load-user-file "init-evil.el")

(require 'color-theme)(color-theme-initialize)(color-theme-charcoal-black)

(require 'magit)
(global-set-key (kbd "C-x C-g") 'magit-status)

(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] '(lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda () (interactive) (scroll-up 1)))
  (defun track-mouse (e))
  (setq mouse-sel-mode t)
)

(add-hook 'find-file-hook (lambda () (linum-mode 1))) ; Line numbers.
(set-face-foreground 'minibuffer-prompt "white") ; White miniprompt.
(setq visible-bell t) ; Disable bell.
(fset 'yes-or-no-p 'y-or-n-p) ; yes/no -> y/n
(setq vc-follow-symlinks t) ; Always follow symlinks.
(add-hook 'emacs-startup-hook  'delete-other-windows)
(setq make-backup-files nil)
(show-paren-mode 1)
(setq show-paren-delay 0)

(setq auto-mode-alist (append '((".aliases" . shell-mode)) auto-mode-alist))
(setq auto-mode-alist (append '((".funcs" . shell-mode)) auto-mode-alist))

(setq shell-prompt-pattern ".*» *")
(setq dired-use-ls-dired nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(defun duplicate-line()
  (interactive)(move-beginning-of-line 1)(kill-line)(yank)(newline)(yank))
(defun duplicate-line-above() (interactive)(duplicate-line)(previous-line))
(global-set-key (kbd "C-c C-d") 'duplicate-line)
(global-set-key (kbd "C-c C-f") 'duplicate-line-above)

(setq inhibit-startup-message t)

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(defun enumerate-list(num-elems)
  (interactive "nNumber of Elements: ")
  (setq i 1)
  (while (<= i num-elems)
    (insert (concat (number-to-string i) ". \n"))
    (incf i)))
(global-set-key (kbd "C-c C-g") 'enumerate-list)
