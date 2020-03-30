(require 'org)
(require 'htmlize)

; (add-to-list 'load-path "~/repos/ox-ipynb")
; (require 'ox-ipynb)

(add-hook 'org-mode-hook (lambda ()
  ;; Dvorak.
  (local-set-key "\M-h" 'org-do-promote)
  (local-set-key "\M-s" 'org-do-demote)
  (local-set-key (kbd "M-S-h") 'org-promote-subtree)
  (local-set-key (kbd "M-S-s") 'org-demote-subtree)

  (local-set-key "\M-t" 'org-metadown)
  (local-set-key "\M-n" 'org-metaup)

  (local-set-key (kbd "C-S-<return>") 'org-insert-heading-after-current)

  (setq indent-tabs-mode nil)
  (setq tap-width 2)
  (setq evil-shift-width 2)
))

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-startup-with-inline-images t
      org-startup-folded nil
      org-src-fontify-natively t
      org-latex-to-pdf-process (list "latexmk -pdf %f")
      org-image-actual-width 600
      org-agenda-skip-scheduled-if-done t
      org-agenda-files '("~/org")
      org-capture-templates '())

; (org-babel-do-load-languages
;  'org-babel-load-languages
; '((sh . t)
;   (python . t)))
;(setq org-confirm-babel-evaluate nil)
;(setq org-babel-python-command "python3")

;; Automatic link description downloading.
;; Source: https://github.com/pkkm/.emacs.d/blob/8ac745bae09e303a13708fb9260849de9e1d8502/conf/mode-specific/org.el#L90

; (use-package s :ensure t :commands s-trim s-collapse-whitespace)
;; (autoload 'mm-url-decode-entities-string "mm-url")
;; (defun get-url-html-title (url &rest ignored)
;; "Return the title of the HTML page at URL."
;; (let ((download-buffer (url-retrieve-synchronously url))
;;         title-start title-end)
;;     (save-excursion
;;     (set-buffer download-buffer)
;;     (beginning-of-buffer)
;;     (setq title-start (search-forward "<title>"))
;;     (search-forward "</title>")
;;     (setq title-end (search-backward "<"))
;;     (s-trim
;;         (s-collapse-whitespace
;;         (mm-url-decode-entities-string
;;         (buffer-substring-no-properties title-start title-end)))))))

;; https://github.com/jmn/dotfiles/blob/c84bba70fbcf52126b4d9b34e2794b73327048b3/tag-emacs/emacs.d/config-jmn-functions.el
(defun url-get-title (url &optional descr)
  "Takes a URL and returns the value of the <title> HTML tag,
   Thanks to https://frozenlock.org/tag/url-retrieve/ for documenting url-retrieve
   customize org-make-link-description-function."
  (let ((buffer (url-retrieve-synchronously url))
        (title nil))
    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min))
      (search-forward-regexp "<title>\\([^<]+?\\)</title>")
      (setq title (match-string 1 ) )
      (kill-buffer (current-buffer)))
    title))

(defun my-org-toggle-auto-link-description ()
"Toggle automatically downloading link descriptions."
(interactive)
(if org-make-link-description-function
    (progn
        (setq org-make-link-description-function nil)
        (message "Automatic link description downloading disabled."))
  (setq org-make-link-description-function (quote url-get-title))
  (message "Automatic link description downloading enabled.")))

;; Source: http://stackoverflow.com/a/27043756
(defun my-org-archive-done-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (outline-previous-heading)))
   "/DONE" 'file))


;;; TODO: Clean all of this up at some point.

(defun org-export-deterministic-reference (references) 0)
    ;; (let ((new 0))
       ;; (while (rassq new references) (setq new (+ new 1)))
       ;; new))
(advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)
;; (advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)


;;; From https://github.com/bryal/.emacs.d/blob/c5ee3d62a47a08c1f8da9e27584d42e5089aa21d/lisp/custom-org-html.el
(require 'ox-html)


(defun headline? (datum)
  (eq (car datum) 'headline))

(defun get-raw-value (datum)
  (plist-get (cadr datum) :raw-value))

(defun custom-org-export-get-reference (datum info)
  "Return a unique reference for DATUM, as a string.

DATUM is either an element or an object.  INFO is the current
export state, as a plist.

This function checks `:crossrefs' property in INFO for search
cells matching DATUM before creating a new reference.  Returned
reference consists of alphanumeric characters only."
  (let ((cache (plist-get info :internal-references)))
    (or (car (rassq datum cache))
	(let* ((crossrefs (plist-get info :crossrefs))
	       (cells (org-export-search-cells datum))
	       ;; Preserve any pre-existing association between
	       ;; a search cell and a reference, i.e., when some
	       ;; previously published document referenced a location
	       ;; within current file (see
	       ;; `org-publish-resolve-external-link').
	       ;;
	       ;; However, there is no guarantee that search cells are
	       ;; unique, e.g., there might be duplicate custom ID or
	       ;; two headings with the same title in the file.
	       ;;
	       ;; As a consequence, before re-using any reference to
	       ;; an element or object, we check that it doesn't refer
	       ;; to a previous element or object.
	       (new (or (cl-some
			 (lambda (cell)
			   (let ((stored (cdr (assoc cell crossrefs))))
			     (when stored
			       (let ((old (org-export-format-reference stored)))
				 (and (not (assoc old cache)) stored)))))
			 cells)
			(org-export-new-reference cache)))
               (new-ref (org-export-format-reference new))
               (reference-string
                (if (headline? datum)
                    (concat (replace-regexp-in-string " " "-" (get-raw-value datum))
                            "-" new-ref)
                             new-ref)
                ))
	  ;; Cache contains both data already associated to
	  ;; a reference and in-use internal references, so as to make
	  ;; unique references.
	  (dolist (cell cells) (push (cons cell new) cache))
	  ;; Retain a direct association between reference string and
	  ;; DATUM since (1) not every object or element can be given
	  ;; a search cell (2) it permits quick lookup.
	  (push (cons reference-string datum) cache)
	  (plist-put info :internal-references cache)
	  reference-string))))

(advice-add #'org-export-get-reference :override #'custom-org-export-get-reference)
