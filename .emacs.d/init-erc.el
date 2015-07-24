(require 'erc)

(setq erc-user-full-name "Brandon Amos")
(setq erc-email-userid "bamos@cs.cmu.edu")

; See http://www.emacswiki.org/emacs/ErcNickserv
(load "~/.ercpass")
(require 'erc-services)
(erc-services-mode 1)
(setq erc-prompt-for-nickserv-password nil)
(setq erc-nickserv-passwords
      `((freenode (("bdamos" . ,freenode-pass)))
        (OFTC (("bdamos" . ,oftc-pass)))))
        ;; (127\.0\.0\.1 (("bdamos" . ,bitlbee-pass)))))
(custom-set-variables
 '(erc-autojoin-timing 'ident)
 '(erc-autojoin-delay 10))

(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                "324" "329" "332" "333" "353" "477"))
(setq erc-hide-list '("JOIN" "PART" "QUIT"))

(setq erc-echo-notices-in-minibuffer-flag t)

;; Logging
(erc-log-mode t)
(setq erc-log-insert-log-on-open nil)
(setq erc-log-channels t)
(setq erc-log-channels-directory "~/.irclogs/")
(setq erc-save-buffer-on-part t)
(setq erc-hide-timestamps nil)

(defadvice save-buffers-kill-emacs (before save-logs (arg) activate)
  (save-some-buffers t (lambda () (when (and (eq major-mode 'erc-mode)
                                             (not (null buffer-file-name)))))))

(add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)
(add-hook 'erc-mode-hook
          '(lambda () (when (not (featurep 'xemacs))
                        (set (make-variable-buffer-local
                              'coding-system-for-write)
                             'emacs-mule))))

(add-to-list 'erc-mode-hook
             (lambda () (set (make-local-variable 'scroll-conservatively) 100)))

(setq erc-max-buffer-size 20000)
(defvar erc-insert-post-hook)
(add-hook 'erc-insert-post-hook 'erc-truncate-buffer)
(setq erc-truncate-buffer-on-save t)

(setq whitespace-global-modes '(not erc-mode))

;; http://www.emacswiki.org/emacs/ErcAutoQuery
(setq erc-auto-query 'buffer)
(add-hook 'erc-after-connect
          (lambda (server nick)
            (add-hook 'erc-server-NOTICE-hook 'erc-auto-query)))

(require 'erc-match)
(setq erc-keywords '("bdamos"))

(require 'erc-join)
(erc-autojoin-mode 1)

;; # Interesting channels
;; ## freenode.net
;;   "#android" "#android-dev" "#archlinux" "#archlinux-offtopic"
;;   "#bash" "##c" "##c++" "##cclub" "#cslounge" "#emacs" "#erlang"
;;   "#gentoo" "#git" "#github" "#haskell" "##hh" "##linux" "#MacOSX"
;;   "#machinelearning" "#math" "#mutt" "#music" "#networking" "#programming"
;;   "#python" "#ruby" "#scala" "#vim" "#xmonad" "#zsh"
;; ## oftc.net
;;   "#vtluug" "#tor" "#suckless"
(setq erc-autojoin-channels-alist
      '(("freenode.net" "##cs" "##computerscience" "##cclub" "#cslounge"
         "#haskell" "#machinelearning"
         "#math" "#mutt" "#music" "#perl" "#scala" "#statistics")
        ("oftc.net" "#vtluug")))
        ;; ("127.0.0.1" "&bitlbee")))

(defun irc-maybe ()
  (interactive)
  (when (y-or-n-p "IRC? ")
    (erc :server "irc.freenode.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")
    (erc :server "irc.oftc.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")))
    ;; (erc :server "127.0.0.1" :port 6667
         ;; :nick "bdamos" :full-name "Brandon Amos")))
