(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

(setq ispell-program-name "aspell"
      ispell-personal-dictionary "~/.aspell.en.pws")

(if (eq system-type 'darwin)
    (setq ispell-program-name "/opt/homebrew/bin/aspell")
    (setq ispell-program-name "/usr/bin/aspell"))

(setq ispell-tex-skip-alists
      (list
       (append
        (car ispell-tex-skip-alists)
        '(
          ("\\\\citep" ispell-tex-arg-end)
          ("\\\\citet" ispell-tex-arg-end)
          ("\\\\cite" ispell-tex-arg-end)
          ("\\\\href" ispell-tex-arg-end)
          ("\\\\bibliography" ispell-tex-arg-end)
          ("[^\\]\\$" . "[^\\]\\$")
          ("\\\\begin{tabular}" . "$")
          ("\\\\begin{equation}" . "\\\\end{equation}")
          ("\\\\iffalse" . "\\\\fi")
          ))
       (cadr ispell-tex-skip-alists)))
