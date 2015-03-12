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

(require 'ess-site)
(setq ess-indent-level 2)
(setq ess-default-style 'OWN)
(setq ess-toggle-underscore nil)

(require 'org)

; (require 'protobuf-mode)
; (add-to-list 'auto-mode-alist '("\\.prototxt\\'" . yaml-mode))

; (require 'scala-mode2)
(require 'puppet-mode)

(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
