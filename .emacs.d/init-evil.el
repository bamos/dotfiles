; Source: https://raw.githubusercontent.com/terhechte/emacs.d/master/modes-init/init-evil.el

(setq evil-want-C-u-scroll t)
(setq evil-want-fine-undo t)
(require 'evil)
(evil-mode 1)

;; New is C-g
(define-key evil-insert-state-map "\C-g" 'evil-normal-state)

;; http://dnquark.com/blog/2012/02/emacs-evil-ecumenicalism/
;; I want c-n / c-p to work like in emacs
(define-key evil-insert-state-map "\C-e" 'end-of-line)
(define-key evil-visual-state-map "\C-e" 'evil-end-of-line)
(define-key evil-normal-state-map "\C-f" 'evil-forward-char)
(define-key evil-insert-state-map "\C-f" 'evil-forward-char)
(define-key evil-insert-state-map "\C-f" 'evil-forward-char)
(define-key evil-normal-state-map "\C-b" 'evil-backward-char)
(define-key evil-insert-state-map "\C-b" 'evil-backward-char)
(define-key evil-visual-state-map "\C-b" 'evil-backward-char)
(define-key evil-normal-state-map "\C-n" 'evil-next-line)
(define-key evil-insert-state-map "\C-n" 'evil-next-line)
(define-key evil-visual-state-map "\C-n" 'evil-next-line)
(define-key evil-normal-state-map "\C-p" 'evil-previous-line)
(define-key evil-insert-state-map "\C-p" 'evil-previous-line)
(define-key evil-visual-state-map "\C-p" 'evil-previous-line)
(define-key evil-normal-state-map "\C-y" 'yank)
(define-key evil-insert-state-map "\C-y" 'yank)
(define-key evil-visual-state-map "\C-y" 'yank)
(define-key evil-normal-state-map "\C-k" 'kill-line)
(define-key evil-insert-state-map "\C-k" 'kill-line)
(define-key evil-visual-state-map "\C-k" 'kill-line)
(define-key evil-normal-state-map (kbd "TAB") 'evil-undefine)

; http://stackoverflow.com/questions/8483182/emacs-evil-mode-best-practice



(defun evil-undefine ()
 (interactive)
 (let (evil-mode-map-alist)
   (call-interactively (key-binding (this-command-keys)))))
 
;;; esc quits
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

; load evil leader
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader ",")

(define-key evil-normal-state-map (kbd "C-.") 'execute-extended-command)
(define-key evil-visual-state-map (kbd "C-.") 'execute-extended-command)

(require 'evil-numbers)
(global-set-key (kbd "C-c +") 'evil-numbers/inc-at-pt)
(global-set-key (kbd "C-c -") 'evil-numbers/dec-at-pt)

(require 'evil-surround)(global-evil-surround-mode 1)
(require 'evil-nerd-commenter)(evilnc-default-hotkeys)
(require 'powerline)(powerline-center-evil-theme)
