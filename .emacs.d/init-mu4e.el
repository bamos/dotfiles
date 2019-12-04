(add-to-list 'load-path "/usr/local/Cellar/mu/1.2.0_1/share/emacs/site-lisp/mu/mu4e")
(require 'mu4e)

(setq user-full-name "Brandon Amos"
        user-mail-address "brandon.amos.cs@gmail.com"
        message-send-mail-function 'smtpmail-send-it
        smtpmail-local-domain "gmail.com"
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        smtpmail-queue-mail nil
        smtpmail-queue-dir "~/.mu/queue/cur"
        mu4e-maildir "~/mbsync"
        ;; mu4e-drafts-folder "/[Gmail].Drafts"
        mu4e-sent-folder   "/[Gmail].Sent Mail"
        mu4e-refile-folder   "/[Gmail].All Mail"
        mu4e-trash-folder  "/[Gmail].Trash"
        mu4e-sent-messages-behavior 'delete
        mu4e-mu-binary "/usr/local/Cellar/mu/1.2.0_1/bin/mu"
        message-kill-buffer-on-exit t
        mu4e-maildir-shortcuts
        '( ("/INBOX"               . ?i)
            ("/[Gmail].Sent Mail"   . ?s)
            ("/[Gmail].Trash"       . ?t)
            ;; ("/[Gmail].Drafts"      . ?d)
            ("/[Gmail].All Mail"    . ?a))
        mu4e-get-mail-command "mbsync gmail"
        mu4e-update-interval (* 10 60)
        mu4e-view-image-max-width 800
        mu4e-view-show-images t
        mu4e-view-show-addresses t
        mu4e-change-filenames-when-moving t
        mu4e-hide-index-messages 1
        mu4e-confirm-quit nil
        mu4e-headers-leave-behavior 'apply
        mu4e-compose-complete-only-personal t)
(when (fboundp 'imagemagick-register-types)
    (imagemagick-register-types))
(defun my-mu4e-mark-execute-all-no-confirm ()
    (interactive)
    (mu4e-mark-execute-all 'no-confirm))
(eval-after-load 'mu4e
    '(progn
        (define-key mu4e-headers-mode-map "x" #'my-mu4e-mark-execute-all-no-confirm)))

;; https://emacs.stackexchange.com/a/24430
(defun draft-auto-save-buffer-name-handler (operation &rest args)
    "for `make-auto-save-file-name' set '.' in front of the file name; do nothing for other operations"
    (if
        (and buffer-file-name (eq operation 'make-auto-save-file-name))
        (concat (file-name-directory buffer-file-name)
                "."
                (file-name-nondirectory buffer-file-name))
    (let ((inhibit-file-name-handlers
            (cons 'draft-auto-save-buffer-name-handler
                    (and (eq inhibit-file-name-operation operation)
                        inhibit-file-name-handlers)))
            (inhibit-file-name-operation operation))
        (apply operation args))))

(add-to-list 'file-name-handler-alist '("Drafts/cur/" . draft-auto-save-buffer-name-handler))
