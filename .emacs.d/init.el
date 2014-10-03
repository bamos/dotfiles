(defconst user-init-dir
  (cond
    ((boundp 'user-emacs-directory) user-emacs-directory)
    ((boundp 'user-init-directory) user-init-directory)
    (t "~/.emacs.d/")))

(defun load-user-file (file) (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(load-user-file "packages.el")

(require 'evil)
(evil-mode 1)

(setq make-backup-files nil)
