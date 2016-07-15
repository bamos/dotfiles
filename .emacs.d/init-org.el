(require 'org)

(add-hook 'org-mode-hook (lambda ()
  ;; Dvorak.
  (local-set-key "\M-h" 'org-do-promote)
  (local-set-key "\M-s" 'org-do-demote)
  (local-set-key (kbd "M-S-h") 'org-promote-subtree)
  (local-set-key (kbd "M-S-s") 'org-demote-subtree)

  (local-set-key "\M-t" 'org-metadown)
  (local-set-key "\M-n" 'org-metaup)

  (local-set-key (kbd "C-c a") 'org-agenda)

  (local-set-key (kbd "C-S-<return>") 'org-insert-heading-after-current)))

(org-display-inline-images)

;; Automatic link description downloading.
;; Source: https://github.com/pkkm/.emacs.d/blob/8ac745bae09e303a13708fb9260849de9e1d8502/conf/mode-specific/org.el#L90

; (use-package s :ensure t :commands s-trim s-collapse-whitespace)
(autoload 'mm-url-decode-entities-string "mm-url")
(defun get-url-html-title (url &rest ignored)
"Return the title of the HTML page at URL."
(let ((download-buffer (url-retrieve-synchronously url))
        title-start title-end)
    (save-excursion
    (set-buffer download-buffer)
    (beginning-of-buffer)
    (setq title-start (search-forward "<title>"))
    (search-forward "</title>")
    (setq title-end (search-backward "<"))
    (s-trim
        (s-collapse-whitespace
        (mm-url-decode-entities-string
        (buffer-substring-no-properties title-start title-end)))))))

(defun my-org-toggle-auto-link-description ()
"Toggle automatically downloading link descriptions."
(interactive)
(if org-make-link-description-function
    (progn
        (setq org-make-link-description-function nil)
        (message "Automatic link description downloading disabled."))
    (setq org-make-link-description-function #'get-url-html-title)
    (message "Automatic link description downloading enabled.")))
