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
    f
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

(dolist (p required-packages)
  (when (not (package-installed-p p))
    (package-refresh-contents)
    (package-install p)))

(use-package quelpa
  :config
  (use-package quelpa-use-package)
  (setq quelpa-update-melpa-p nil)
  (quelpa-use-package-activate-advice))

(require 'use-package)
(require 'quelpa-use-package)
(setq use-package-always-ensure t)

