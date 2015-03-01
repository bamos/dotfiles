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
(custom-set-variables
 '(erc-autojoin-timing 'ident)
 '(erc-autojoin-delay 10))
(setq erc-auto-query 'buffer)

(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                "324" "329" "332" "333" "353" "477"))
(setq erc-hide-list '("JOIN" "PART" "QUIT"))

(setq erc-echo-notices-in-minibuffer-flag t)

(setq erc-log-insert-log-on-open nil)
(setq erc-log-channels t)
(setq erc-log-channels-directory "~/.irclogs/")
(setq erc-save-buffer-on-part t)
(setq erc-hide-timestamps nil)

(add-to-list 'erc-mode-hook
             (lambda () (set (make-local-variable 'scroll-conservatively) 100)))

(setq erc-max-buffer-size 20000)
(defvar erc-insert-post-hook)
(add-hook 'erc-insert-post-hook 'erc-truncate-buffer)
(setq erc-truncate-buffer-on-save t)

(setq whitespace-global-modes '(not erc-mode))

(require 'erc-match)
(setq erc-keywords '("bdamos"))

(require 'erc-join)
(erc-autojoin-mode 1)
(setq erc-autojoin-channels-alist
      '(("freenode.net"
         "#android" "#android-dev"
         "#archlinux" "#archlinux-offtopic"
         "##cclub" "#cslounge"
         "#emacs" "#github" "#haskell" "##linux"
         "#machinelearning" "#math" "#mutt" "#music"
         "#programming" "#python" "#scala" "#zsh")
        ("oftc.net" "#vtluug")))

(defun irc-maybe ()
  (interactive)
  (when (y-or-n-p "IRC? ")
    (erc :server "irc.freenode.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")
    (erc :server "irc.oftc.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")))
