(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(setq ispell-program-name "aspell"
      ispell-program-name "/usr/bin/aspell"
      ispell-personal-dictionary "~/.aspell.en.pws")

(setq ispell-tex-skip-alists
      (list
       (append
        (car ispell-tex-skip-alists)
        '(
          ("\\\\citep" ispell-tex-arg-end)
          ("\\\\citet" ispell-tex-arg-end)
          ("\\\\cite" ispell-tex-arg-end)
          ("\\\\bibliography" ispell-tex-arg-end)
          ))
       (cadr ispell-tex-skip-alists)))
