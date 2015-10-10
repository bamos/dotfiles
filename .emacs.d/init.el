; (package-initialize)

(defconst user-init-dir (cond
  ((boundp 'user-emacs-directory) user-emacs-directory)
  ((boundp 'user-init-directory) user-init-directory)
  (t "~/.emacs.d/")))

(defun load-user-file (file) (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(load-user-file "packages.el")

(load-user-file "clipboard.el")
(load-user-file "funcs.el")
(load-user-file "mail.el")

(load-user-file "init-auctex.el")
(load-user-file "init-ensime.el")
(load-user-file "init-ess.el")
(load-user-file "init-evil.el")
(load-user-file "init-w3m.el")
(load-user-file "init-web-mode.el")
(load-user-file "init-flyspell.el")

(when (file-exists-p "~/.ercpass") (load-user-file "init-erc.el"))

;; The `charcoal-black` theme leaves the default colors in `w3m-mode`.
;; First load the zenburn theme for better colors in `w3m-mode`,
;; then use `charcoal-black` for everything else
(load-theme 'zenburn t)
(require 'color-theme)(color-theme-initialize)(color-theme-charcoal-black)

(require 'magit)
(global-set-key (kbd "C-x C-g C-s") 'magit-status)
(setq magit-push-always-verify nil)

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

(setq compilation-scroll-output 'first-error)

(add-hook 'python-mode-hook (lambda() (
  (setq-default tab-width 4)(setq sh-basic-offset 4)(setq sh-indentation 4))))

(require 'haskell-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(require 'org)
(require 'puppet-mode)

(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.emacs.d/snippets/yasnippet-snippets"
        "~/.emacs.d/snippets/yasmate/snippets"
        ))
(yas-global-mode 1)

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
