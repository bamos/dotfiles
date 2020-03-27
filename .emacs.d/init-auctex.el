(setq-default TeX-PDF-mode t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)

(if (eq system-type 'darwin)
  (progn
    (setq TeX-view-program-list '(("open" "open %o")))
    (setq TeX-view-program-selection '((output-pdf "open")))
    (setenv "PATH" (concat (getenv "PATH") "/Library/TeX/texbin:/usr/local/bin"))
    (setq exec-path (append exec-path '("/Library/TeX/texbin" "/usr/local/bin"))))
  (progn
    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
          TeX-source-correlate-start-server t)
    (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)))
