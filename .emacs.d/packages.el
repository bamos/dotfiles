(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(defvar required-packages '(
    auctex
    color-theme
    dash
    ensime
    evil
    evil-leader
    evil-nerd-commenter
    evil-numbers
    evil-surround
    erc
    ess
    flycheck
    free-keys
    git-messenger
    go-mode
    haskell-mode
    helm-core
    htmlize
    json-mode
    lua-mode
    magit
    markdown-mode
    multiple-cursors
    rfringe
    ;; scala-mode2
    smooth-scroll
    org
    popup
    powerline
    projectile
    protobuf-mode
    puppet-mode
    python-mode
    w3m
    web-mode
    xclip
    yasnippet
    yaml-mode
    zenburn-theme
  )
  "Packages which should be installed upon launch"
)

(dolist (p required-packages)
  (when (not (package-installed-p p))
    (package-refresh-contents)
    (package-install p)))
