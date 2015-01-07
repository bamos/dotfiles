(defconst user-init-dir (cond
  ((boundp 'user-emacs-directory) user-emacs-directory)
  ((boundp 'user-init-directory) user-init-directory)
  (t "~/.emacs.d/")))

(defun load-user-file (file) (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(load-user-file "packages.el")
(load-user-file "clipboard.el")
(load-user-file "init-evil.el")
(when (file-exists-p "~/.ercpass") (load-user-file "init-erc.el"))
(load-user-file "modes.el")
(load-user-file "funcs.el")
(load-user-file "mail.el")

(require 'color-theme)(color-theme-initialize)(color-theme-charcoal-black)

(require 'magit)
(global-set-key (kbd "C-c m") 'magit-status)

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
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(show-paren-mode 1)
(setq show-paren-delay 0)

(setq shell-prompt-pattern ".*» *")
(setq dired-use-ls-dired nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)(setq sh-basic-offset 2)(setq sh-indentation 2)

(setq-default show-trailing-whitespace t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(require 'saveplace)
(setq save-place-file (concat user-emacs-directory "saveplace.el") )
(setq-default save-place t)

; Disable menu and tool bars.
(menu-bar-mode -99)
(tool-bar-mode -1)

(transient-mark-mode 1)

; Re-initialize mouse mode for tmux.
(defun my-terminal-config (&optional frame)
  (if xterm-mouse-mode (xterm-mouse-mode 1)))
(add-hook 'after-make-frame-functions 'my-terminal-config)
