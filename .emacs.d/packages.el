(require 'package)
(setq package-archives '(
    ("org" . "http://orgmode.org/elpa/")
    ("gnu" . "http://elpa.gnu.org/packages/")
    ("melpa" . "http://melpa.org/packages/")
))
(when (< emacs-major-version 27) (package-initialize))

(defvar required-packages '(
    auctex
    color-theme-modern
    darkroom
    dash
    editorconfig
    evil
    evil-commentary
    evil-leader
    evil-nerd-commenter
    evil-numbers
    evil-surround
    flycheck
    free-keys
    git-messenger
    gptel
    haskell-mode
    helm
    helm-descbinds
    htmlize
    json-mode
    lua-mode
    magit
    markdown-mode
    multiple-cursors
    org
    pdf-tools
    popup
    powerline
    projectile
    protobuf-mode
    puppet-mode
    python-mode
    quelpa
    quelpa-use-package
    s
    smooth-scroll
    undo-tree
    use-package
    w3m
    web-mode
    xclip
    yasnippet
    yaml-mode
    zenburn-theme
  )
  "Packages which should be installed upon launch"
)

(package-refresh-contents)
(dolist (p required-packages)
  (when (not (package-installed-p p))
    (print p)
    (package-install p)))
