(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(setq auto-mode-alist (append '((".aliases" . shell-mode)) auto-mode-alist))
(setq auto-mode-alist (append '((".funcs" . shell-mode)) auto-mode-alist))

(add-hook 'python-mode-hook (lambda() (
  (setq-default tab-width 4)(setq sh-basic-offset 4)(setq sh-indentation 4))))

; (add-hook 'latex-mode-hook (lambda () (setq linum-format "%d ")))

(add-hook 'haskell-mode-hook
          (lambda() ((turn-on-haskell-doc-mode)(turn-on-haskell-indentation))))

; Temporary hack for syntax highlighting in R.
; https://github.com/bamos/dotfiles/issues/16
(add-to-list 'auto-mode-alist '("\\.r\\'" . python-mode))

(require 'org)

; (require 'protobuf-mode)
; (add-to-list 'auto-mode-alist '("\\.prototxt\\'" . protobuf-mode))
