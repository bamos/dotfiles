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
