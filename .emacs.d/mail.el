(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))

(add-hook 'mail-mode-hook 'turn-on-auto-fill)

(add-hook 'mail-mode-hook (lambda ()
   (define-key mail-mode-map [(control c) (control c)]
     (lambda () (interactive) (save-buffer) (save-buffers-kill-terminal)))
   (delete-trailing-whitespace)
   (if (re-search-forward "\n\n" nil t)
     (progn (open-line 2))
     (when (search-forward "Reply-To:" nil t)
       (open-line 2)(next-line 2)))))
