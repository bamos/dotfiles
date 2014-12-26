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

(setq erc-echo-notices-in-minibuffer-flag t)

(setq erc-log-insert-log-on-open nil)
(setq erc-log-channels t)
(setq erc-log-channels-directory "~/.irclogs/")
(setq erc-save-buffer-on-part t)
(setq erc-hide-timestamps nil)

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
      '(("freenode.net" "#android" "#android-dev" "#archlinux"
         "#archlinux-offtopic" "#bash" "#clojure" "##c" "##c++"
         "##cclub" "#cslounge" "#docker" "#emacs" "#erlang"
         "#git" "#github" "#go-nuts" "#haskell" "##linux"
         "#MacOSX" "#math" "#music" "#networking" "#programming"
         "#python" "#Reddit" "#ruby" "#scala" "#security"
         "#startups" "#vim" "#xmonad" "#zsh")
        ("oftc.net" "#vtluug" "#tor" "#suckless")))

(defun irc-maybe ()
  (interactive)
  (when (y-or-n-p "IRC? ")
    (erc :server "irc.freenode.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")
    (erc :server "irc.oftc.net" :port 6667
         :nick "bdamos" :full-name "Brandon Amos")))
