;;; org-image-resize.el --- Drag Org image widths -*- lexical-binding: t; -*-

(require 'org)
(require 'org-element)
(require 'image)
(require 'mouse)
(require 'cl-lib)
(require 'subr-x)

(defgroup my-org-image-resize nil
  "Resize standalone Org images with the mouse."
  :group 'org)

(defcustom my-org-image-resize-handle-width 16
  "Width in pixels of the draggable strip at an image's right edge."
  :type 'integer)

(defvar my-org-image-resize-mode)

(defvar-local my-org-image-resize--hidden-attributes nil
  "Attribute overlays paired with the image previews that need them.")

(defun my-org-image-resize--prune-attributes (&rest _)
  "Reveal attributes whose image preview was removed."
  (setq my-org-image-resize--hidden-attributes
        (cl-delete-if
         (lambda (overlay)
           (when (or (not (overlay-buffer overlay))
                     (not my-org-image-resize-mode)
                     (not (overlay-buffer (overlay-get overlay 'image-owner))))
             (delete-overlay overlay)
             t))
         my-org-image-resize--hidden-attributes)))

(defun my-org-image-resize--hide-attributes (image)
  "Hide width metadata associated with IMAGE without editing the note."
  (when-let* ((paragraph (my-org-image-resize--paragraph (overlay-start image))))
    (save-excursion
      (goto-char (org-element-begin paragraph))
      (let ((case-fold-search t))
        (while (re-search-forward "^[ \t]*#\\+attr_org:.*:width\\b.*$"
                                  (org-element-contents-begin paragraph) t)
          (let ((overlay (make-overlay (line-beginning-position)
                                       (min (point-max) (1+ (line-end-position))))))
            ;; Do not use `invisible': it joins Org's invisible link prefix
            ;; into one hidden run and can suppress the following image.
            (overlay-put overlay 'display "")
            (overlay-put overlay 'evaporate t)
            (overlay-put overlay 'image-owner image)
            (push overlay my-org-image-resize--hidden-attributes)))))))

(defun my-org-image-resize--paragraph (position)
  "Return the standalone image paragraph at POSITION, or nil.
Attributes apply to a whole paragraph, so never resize an image alongside
text or other images.  Keep list markers and other Org syntax intact."
  (save-excursion
    (goto-char position)
    (let* ((link (org-element-context))
           (paragraph (and (eq (org-element-type link) 'link)
                           (org-element-lineage link 'paragraph))))
      (when (and paragraph
                 (string-blank-p
                  (buffer-substring-no-properties
                   (line-beginning-position) (org-element-begin link)))
                 (string-blank-p
                  (buffer-substring-no-properties
                   (org-element-contents-begin paragraph) (org-element-begin link)))
                 (string-blank-p
                  (buffer-substring-no-properties
                   (org-element-end link) (org-element-contents-end paragraph))))
        paragraph))))

(defun my-org-image-resize--save-width (position width)
  "Store WIDTH for the standalone image at POSITION as an Org attribute.
Preserve captions, other attributes, indentation, and the link itself."
  (barf-if-buffer-read-only)
  (unless (and (integerp width) (> width 0))
    (user-error "Image width must be a positive integer"))
  (let ((paragraph (my-org-image-resize--paragraph position)))
    (unless paragraph
      (user-error "Resize an image on a line by itself"))
    (save-excursion
      (let ((end (copy-marker (org-element-contents-begin paragraph) t))
            (case-fold-search t)
            first-attribute found-width)
        (unwind-protect
            (atomic-change-group
              (goto-char (org-element-begin paragraph))
              (while (re-search-forward "^[ \t]*#\\+attr_org:" end t)
                (unless first-attribute
                  (setq first-attribute (point)))
                (while (re-search-forward "[ \t]+:width[ \t]+\\([^ \t\n]+\\)"
                                          (line-end-position) t)
                  (replace-match (number-to-string width) t t nil 1)
                  (setq found-width t))
                (forward-line 1))
              (unless found-width
                (if first-attribute
                    (progn
                      (goto-char first-attribute)
                      (end-of-line)
                      (insert (format " :width %d" width)))
                  (goto-char end)
                  (beginning-of-line)
                  (let ((indent (buffer-substring
                                 (point) (progn (back-to-indentation) (point)))))
                    (beginning-of-line)
                    (insert (format "%s#+ATTR_ORG: :width %d\n" indent width))))))
          (set-marker end nil))))))

(defun my-org-image-resize--track (event overlay width)
  "Preview a drag from EVENT on OVERLAY, initially WIDTH pixels wide.
Return the chosen width on release, or nil for a click or cancellation.
Restore the original preview on exit; the caller saves the final width."
  (let* ((start (event-start event))
         (window (posn-window start))
         (start-x (car (posn-x-y start)))
         (original (overlay-get overlay 'display))
         (preview (copy-tree original))
         (limit (max 32 (window-body-width window t)))
         (mouse-fine-grained-tracking t)
         (auto-hscroll-mode nil)
         chosen done released)
    (unwind-protect
        (progn
          (track-mouse
            (while (not done)
              (let* ((next (read-event))
                     (kind (car-safe next)))
                (cond
                 ((memq kind '(mouse-movement mouse-1 drag-mouse-1))
                  (let ((position (event-end next)))
                    (when (eq (posn-window position) window)
                      (let ((delta (- (car (posn-x-y position)) start-x)))
                        (when (or chosen (>= (abs delta) 3))
                          (setq chosen (max 32 (min limit (round (+ width delta)))))
                          (dolist (key '(:height :max-width :max-height))
                            (setf (image-property preview key) nil))
                          (setf (image-property preview :scale) 1
                                (image-property preview :width) chosen)
                          (overlay-put overlay 'display preview)
                          (force-window-update window)))))
                  (when (memq kind '(mouse-1 drag-mouse-1))
                    (setq released t done t)))
                 (t
                  ;; Let unrelated input run normally after cancelling the drag.
                  (setq unread-command-events (cons next unread-command-events)
                        done t))))))
          (and released chosen (/= chosen width) chosen))
      (when (overlay-buffer overlay)
        (overlay-put overlay 'display original)
        (force-window-update window)))))

(defun my-org-image-resize-drag (event)
  "Drag the right edge of an inline Org image to resize it.
Save the resulting width in #+ATTR_ORG.  Ordinary clicks elsewhere retain
their usual selection behavior.  C-g cancels a resize."
  (interactive "e")
  (let* ((position (event-start event))
         (window (posn-window position))
         (point (posn-point position))
         (xy (posn-object-x-y position)))
    (if (not (and (window-live-p window) (integer-or-marker-p point) xy))
        (mouse-drag-region event)
      (with-current-buffer (window-buffer window)
        (let* ((overlay (cl-find-if (lambda (ov) (overlay-get ov 'org-image-overlay))
                                    (overlays-at point)))
               (image (and overlay (overlay-get overlay 'display)))
               (width (and image (car (image-size image t (window-frame window))))))
          (if (not (and width (not buffer-read-only)
                        (<= 0 (- width (car xy)) my-org-image-resize-handle-width)
                        (my-org-image-resize--paragraph point)))
              (mouse-drag-region event)
            (with-selected-window window
              (let ((marker (copy-marker (overlay-start overlay) t)))
                (unwind-protect
                    (when-let* ((chosen (my-org-image-resize--track event overlay width)))
                      (my-org-image-resize--save-width marker chosen)
                      (save-excursion
                        (goto-char marker)
                        (org-display-inline-images nil t
                                                   (line-beginning-position)
                                                   (line-end-position)))
                      (message "Image width: %d pixels" chosen))
                  (set-marker marker nil))))))))))

(defun my-org-image-resize--decorate (&rest _)
  "Silence image hover text and give standalone images a resize binding."
  (my-org-image-resize--prune-attributes)
  (when my-org-image-resize-mode
    (dolist (overlay org-inline-image-overlays)
      (when (overlay-buffer overlay)
        (unless (overlay-get overlay 'my-org-image-resize-original)
          (overlay-put overlay 'my-org-image-resize-original
                       (list (overlay-get overlay 'keymap)
                             (overlay-get overlay 'help-echo)))
          (when (my-org-image-resize--paragraph (overlay-start overlay))
            (let ((map (make-sparse-keymap)))
              (set-keymap-parent map (or (overlay-get overlay 'keymap) image-map))
              (define-key map [down-mouse-1] #'my-org-image-resize-drag)
              (overlay-put overlay 'keymap map)
              (my-org-image-resize--hide-attributes overlay))))
        ;; Nil falls back to Org's LINK tooltip on the underlying text.
        ;; A function returning nil masks it without showing an empty tooltip.
        (overlay-put overlay 'help-echo #'ignore)))))

(defun my-org-image-resize--after-undo ()
  "Refresh previews after undo or redo changes their width attributes."
  (when (and (derived-mode-p 'org-mode) org-inline-image-overlays
             (memq this-command '(undo undo-only undo-redo evil-undo evil-redo)))
    (org-display-inline-images nil t)))

(define-minor-mode my-org-image-resize-mode
  "Resize standalone Org images by dragging their right edge."
  :global t
  :group 'my-org-image-resize
  (if my-org-image-resize-mode
      (progn
        (advice-add 'org-display-inline-images :after #'my-org-image-resize--decorate)
        (advice-add 'org-remove-inline-images :after #'my-org-image-resize--prune-attributes)
        (advice-add 'org-display-inline-remove-overlay :after #'my-org-image-resize--prune-attributes)
        (add-hook 'post-command-hook #'my-org-image-resize--after-undo))
    (advice-remove 'org-display-inline-images #'my-org-image-resize--decorate)
    (advice-remove 'org-remove-inline-images #'my-org-image-resize--prune-attributes)
    (advice-remove 'org-display-inline-remove-overlay #'my-org-image-resize--prune-attributes)
    (remove-hook 'post-command-hook #'my-org-image-resize--after-undo))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
        (my-org-image-resize--prune-attributes)
        (if my-org-image-resize-mode
            (my-org-image-resize--decorate)
          (dolist (overlay org-inline-image-overlays)
            (when-let* ((original (overlay-get overlay 'my-org-image-resize-original)))
              (overlay-put overlay 'keymap (nth 0 original))
              (overlay-put overlay 'help-echo (nth 1 original))
              (overlay-put overlay 'my-org-image-resize-original nil))))))))

(provide 'org-image-resize)
;;; org-image-resize.el ends here
