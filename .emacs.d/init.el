; (package-initialize)

;; (defconst user-init-dir (cond
;;   ((boundp 'user-emacs-directory) user-emacs-directory)
;;   ((boundp 'user-init-directory) user-init-directory)
;;   (t "~/.emacs.d/")))

(defun load-user-file (file) (interactive "f")
  "Load a file in current user's configuration directory"
  ;; (load-file (expand-file-name file user-init-dir)))
  (load-file (expand-file-name file "~/.emacs.d")))

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
(load-user-file "init-org.el")

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

(add-hook 'find-file-hook (lambda () (linum-mode 0))) ; Line numbers.
(set-face-foreground 'minibuffer-prompt "white") ; White miniprompt.
(fset 'yes-or-no-p 'y-or-n-p) ; yes/no -> y/n
(setq vc-follow-symlinks t) ; Always follow symlinks.
;; (add-hook 'emacs-startup-hook  'delete-other-windows)
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
(defun save-buffer-without-dtw () ; http://stackoverflow.com/questions/14913398
  (interactive)
  (let ((b (current-buffer)))
    (with-temp-buffer
      (let ((before-save-hook (remove 'delete-trailing-whitespace before-save-hook)))
        (with-current-buffer b
          (let ((before-save-hook
                 (remove 'delete-trailing-whitespace before-save-hook)))
            (save-buffer)))))))

(require 'saveplace)
(setq save-place-file (concat user-emacs-directory "saveplace.el") )
(setq-default save-place t)

(if (boundp 'aquamacs-version)
    (progn
      (custom-set-faces
       '(default ((t (:inherit nil :stipple nil :background "Grey15" :foreground "Grey"
                               :inverse-video nil :box nil :strike-through nil
                               :overline nil :underline nil :slant normal
                               :weight normal :height 125 :width normal
                               :foundry "nil" :family "Monaco")))))
      (put 'temporary-file-directory 'standard-value
           '((file-name-as-directory "/tmp")))
      (tool-bar-mode -1))
  (progn
    (menu-bar-mode -1)
    (tool-bar-mode -1)))

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

(require 'puppet-mode)

(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(add-to-list 'auto-mode-alist '("\\.liquid\\'" . web-mode))

(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.emacs.d/snippets/yasnippet-snippets"
        "~/.emacs.d/snippets/yasmate/snippets"
        "~/repos/yasnippet-lua-torch"
        ))
(yas-global-mode 1)

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

(global-set-key (kbd "C-c d") 'redraw-display)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
