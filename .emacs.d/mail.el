(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))

(add-hook 'mail-mode-hook 'turn-on-auto-fill)

(add-hook 'mail-mode-hook (lambda ()
   (define-key mail-mode-map [(control c) (control c)]
     (lambda () (interactive) (save-buffer) (kill-emacs)))
   (delete-trailing-whitespace)
   (next-line 8)(open-line 2)))
