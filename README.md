# Installation

This repo uses git submodules. The simplest setup is:

```sh
git clone --recursive https://github.com/bamos/dotfiles.git
cd dotfiles
./bootstrap.sh
```

If you already cloned without submodules (or switched protocols), run:

```sh
git submodule sync --recursive
git submodule update --init --recursive
```

`bootstrap.sh` creates the symlinks in your home directory and bootstraps
additional programs.

## Org clipboard paste

In graphical Emacs, Command-V and Evil `p`/`P` preserve links from copied
HTML and rich text copied from apps such as TextEdit (RTF), while removing
inline styling. Install Pandoc (`brew install pandoc` on macOS) for rich text
conversion; without it, pasting falls back to plain text. RTF decoding also
uses macOS's built-in `textutil`, preserving Unicode link labels. Rich-text
line breaks become ordinary newlines without visible Org break markers.
Copying Org web or email links also publishes HTML and RTF, plus readable
plain text, for pasting into other macOS apps. Copying a local image publishes
PNG and TIFF pixels; selections containing text and images publish embedded
HTML and RTFD attachments. Image width metadata is omitted from those external
representations. The original Org text and Evil yank properties stay intact
inside Emacs. This uses a small native
helper built with Apple's command-line tools and cached under
`~/.cache/emacs/org-clipboard/`. Toggle with `M-x my-org-rich-copy-mode`.
Clipboard images are saved in an `images/` directory beside the current Org
file and displayed inline. Set `my-org-image-paste-directory` to an absolute
path to use a shared image directory instead. Pasting byte-identical image
data reuses a file already in that folder, including after an Emacs restart.
Re-encoded images with different bytes may still get separate files.
Repasting existing local image links also refreshes their previews, including
pastes from history or registers.
Embedded image data in incoming HTML is saved there as well.

Inline images default to at most half the current window's width, without
enlarging small images. Drag an image's right edge to resize it, keeping its
aspect ratio. Resizing applies to images in their own paragraphs. Widths are
saved as `#+ATTR_ORG` metadata, hidden while previews are displayed. Toggle
inline images to see the metadata. Image hover text is suppressed.

Press `C-g` to cancel a resize; ordinary undo reverses a completed resize.
Toggle with `M-x my-org-image-resize-mode`.

The text and image modules share clipboard format checks in
`.emacs.d/org-paste-common.el`. Copies made inside Emacs retain their original
text and Evil's line/rectangle paste behavior. Toggle the modules with
`M-x my-org-html-paste-mode` and `M-x my-org-image-paste-mode`.

Run the regression suites with:

```sh
emacs --batch -Q -l .emacs.d/tests/org-clipboard-roundtrip-test.el \
  -f ert-run-tests-batch-and-exit
```

The round-trip suite loads all clipboard and resize regressions. Its simulated
app matrix covers standard copy, Evil character and line copies, and each paste
command, across internal copies, HTML/RTF text, PNG/TIFF images, and HTML with
embedded images. Native format checks use a separate test pasteboard. Graphical
tests additionally exercise Command-V, `p`, and `P` and hit-test the rendered
images; run these with `M-x ert` in graphical Emacs.
