(use-package tex
  :ensure auctex
  :defer t
  :init
  (setq-default TeX-PDF-mode t
                TeX-auto-save t
                TeX-parse-self t)
  :config
  (if (eq system-type 'darwin)
      (progn
        (setq TeX-view-program-selection '((output-pdf "Skim"))
              TeX-view-program-list
              '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")
                ("open" "open %o")))
        (setenv "PATH" (concat (getenv "PATH") "/Library/TeX/texbin:/usr/local/bin"))
        (setq exec-path (append exec-path '("/Library/TeX/texbin" "/usr/local/bin"))))
    (setq TeX-view-program-list '(("zathura" "zathura %o"))
          TeX-view-program-selection '((output-pdf "zathura")))))
