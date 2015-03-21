(setq-default TeX-PDF-mode t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)

(if (eq system-type 'darwin)
  (progn
    (setq TeX-view-program-list '(("open" "open %o")))
    (setq TeX-view-program-selection '((output-pdf "open"))))
  (progn
    (setq TeX-view-program-list '(("zathura" "zathura %o")))
    (setq TeX-view-program-selection '((output-pdf "zathura")))))
