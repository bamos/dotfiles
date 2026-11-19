;;; org-image-resize-test.el --- Image drag regressions -*- lexical-binding: t; -*-

(require 'ert)
(load (expand-file-name "../org-image-resize.el"
                        (file-name-directory load-file-name)))

(defmacro org-image-resize-test-with-note (text &rest body)
  "Run BODY at the first link in an Org buffer containing TEXT."
  (declare (indent 1))
  `(with-temp-buffer
     (org-mode)
     (insert ,text)
     (goto-char (point-min))
     (search-forward "[[")
     (backward-char 2)
     ,@body))

(ert-deftest org-image-resize-saves-width-and-preserves-caption ()
  (org-image-resize-test-with-note
      "#+CAPTION: Example figure\n#+NAME: example\n[[file:images/example.png]]\n"
    (my-org-image-resize--save-width (point) 320)
    (should (equal (buffer-string)
                   "#+CAPTION: Example figure\n#+NAME: example\n#+ATTR_ORG: :width 320\n[[file:images/example.png]]\n"))
    (search-forward "[[")
    (backward-char 2)
    (let ((org-image-actual-width nil))
      (should (= (org-display-inline-image--width (org-element-context)) 320)))))

(ert-deftest org-image-resize-preserves-other-attributes-and-updates-all-widths ()
  (org-image-resize-test-with-note
      "#+attr_org: :align center :width 500\n#+ATTR_ORG: :width 60%\n#+ATTR_HTML: :width 900\n[[file:example.png]]\n"
    (my-org-image-resize--save-width (point) 240)
    (should (equal (buffer-string)
                   "#+attr_org: :align center :width 240\n#+ATTR_ORG: :width 240\n#+ATTR_HTML: :width 900\n[[file:example.png]]\n"))))

(ert-deftest org-image-resize-adds-width-to-existing-attribute ()
  (org-image-resize-test-with-note
      "#+ATTR_ORG: :align center\n[[file:example.png]]\n"
    (my-org-image-resize--save-width (point) 250)
    (should (equal (buffer-string)
                   "#+ATTR_ORG: :align center :width 250\n[[file:example.png]]\n"))))

(ert-deftest org-image-resize-keeps-list-indentation-and-other-images ()
  (org-image-resize-test-with-note
      "- Example\n\n  [[file:first.png]]\n\n  [[file:second.png]]\n"
    (my-org-image-resize--save-width (point) 300)
    (should (equal (buffer-string)
                   "- Example\n\n  #+ATTR_ORG: :width 300\n  [[file:first.png]]\n\n  [[file:second.png]]\n"))))

(ert-deftest org-image-resize-rejects-shared-paragraphs-without-editing ()
  (dolist (text '("Text [[file:example.png]]\n"
                  "[[file:first.png]]\n[[file:second.png]]\n"
                  "- [[file:example.png]]\n"
                  "[[file:example.png]] trailing text\n"))
    (org-image-resize-test-with-note text
      (should-error (my-org-image-resize--save-width (point) 300) :type 'user-error)
      (should (equal (buffer-string) text)))))

(ert-deftest org-image-resize-rejects-read-only-and-invalid-widths ()
  (org-image-resize-test-with-note "[[file:example.png]]\n"
    (dolist (width '(0 -1 1.5 nil))
      (should-error (my-org-image-resize--save-width (point) width) :type 'user-error))
    (let ((buffer-read-only t))
      (should-error (my-org-image-resize--save-width (point) 300) :type 'buffer-read-only))
    (should (equal (buffer-string) "[[file:example.png]]\n"))))

(ert-deftest org-image-resize-width-change-is-undoable ()
  (org-image-resize-test-with-note "[[file:example.png]]\n"
    (buffer-enable-undo)
    (my-org-image-resize--save-width (point) 300)
    (undo-boundary)
    (undo 1)
    (should (equal (buffer-string) "[[file:example.png]]\n"))))

(defun org-image-resize-test-event (kind x &optional start)
  "Make a mouse event of KIND at X, with optional drag START."
  (let ((position (list (selected-window) 1 (cons x 10) 0)))
    (if start (list kind start position) (list kind position))))

(defmacro org-image-resize-test-with-drag (&rest body)
  "Run BODY with a synthetic image overlay and pixel-precise mouse input."
  (declare (indent 0))
  `(org-image-resize-test-with-note "[[file:example.png]]\n"
     (let* ((overlay (make-overlay (point-min) (1- (point-max))))
            (original '(image :type png :file "example.png" :width 200 :scale 1))
            (down (org-image-resize-test-event 'down-mouse-1 200)))
       (overlay-put overlay 'display original)
       (cl-letf (((symbol-function 'window-body-width) (lambda (&rest _) 600)))
         ,@body))))

(ert-deftest org-image-resize-drag-previews-and-returns-final-width ()
  (org-image-resize-test-with-drag
    (let ((events (list (org-image-resize-test-event 'mouse-movement 260)
                        (org-image-resize-test-event 'drag-mouse-1 300 (event-start down))))
          preview-width)
      (cl-letf (((symbol-function 'read-event)
                 (lambda (&rest _)
                   (when (= (length events) 1)
                     (setq preview-width (image-property (overlay-get overlay 'display) :width)))
                   (pop events))))
        (should (= (my-org-image-resize--track down overlay 200) 300)))
      (should (= preview-width 260))
      (should (eq (overlay-get overlay 'display) original))
      (should (equal (buffer-string) "[[file:example.png]]\n")))))

(ert-deftest org-image-resize-drag-clamps-at-sensible-limits ()
  (dolist (example '((-200 . 32) (900 . 600)))
    (org-image-resize-test-with-drag
      (cl-letf (((symbol-function 'read-event)
                 (lambda (&rest _) (org-image-resize-test-event 'mouse-1 (car example)))))
        (should (= (my-org-image-resize--track down overlay 200) (cdr example)))))))

(ert-deftest org-image-resize-click-without-drag-does-not-set-a-width ()
  (org-image-resize-test-with-drag
    (cl-letf (((symbol-function 'read-event)
               (lambda (&rest _) (org-image-resize-test-event 'mouse-1 201))))
      (should-not (my-org-image-resize--track down overlay 200))
      (should (eq (overlay-get overlay 'display) original)))))

(ert-deftest org-image-resize-cancel-restores-preview-and-preserves-input ()
  (org-image-resize-test-with-drag
    (let ((events (list (org-image-resize-test-event 'mouse-movement 300) ?x))
          (unread-command-events nil))
      (cl-letf (((symbol-function 'read-event) (lambda (&rest _) (pop events))))
        (should-not (my-org-image-resize--track down overlay 200)))
      (should (equal unread-command-events '(?x)))
      (should (eq (overlay-get overlay 'display) original)))))

(ert-deftest org-image-resize-quit-restores-preview ()
  (org-image-resize-test-with-drag
    (let ((calls 0) caught)
      (cl-letf (((symbol-function 'read-event)
                 (lambda (&rest _)
                   (if (= (cl-incf calls) 1)
                       (org-image-resize-test-event 'mouse-movement 300)
                     (signal 'quit nil)))))
        (condition-case nil
            (my-org-image-resize--track down overlay 200)
          (quit (setq caught t))))
      (should caught)
      (should (eq (overlay-get overlay 'display) original)))))

(ert-deftest org-image-resize-map-is-local-and-reversible ()
  (org-image-resize-test-with-drag
    (let ((org-inline-image-overlays (list overlay))
          (my-org-image-resize-mode nil))
      (overlay-put overlay 'keymap image-map)
      (overlay-put overlay 'help-echo "Original help")
      (put-text-property (overlay-start overlay) (overlay-end overlay)
                         'help-echo "LINK: file:example.png")
      (unwind-protect
          (progn
            (my-org-image-resize-mode 1)
            (should (eq (lookup-key (overlay-get overlay 'keymap) [down-mouse-1])
                        #'my-org-image-resize-drag))
            (should (eq (get-char-property (overlay-start overlay) 'help-echo) #'ignore))
            (should-not (funcall (get-char-property (overlay-start overlay) 'help-echo)
                                nil overlay (overlay-start overlay)))
            (should-not (lookup-key image-map [down-mouse-1]))
            (my-org-image-resize--decorate)
            (my-org-image-resize-mode -1)
            (should (eq (overlay-get overlay 'keymap) image-map))
            (should (equal (overlay-get overlay 'help-echo) "Original help")))
        (my-org-image-resize-mode -1)))))

(ert-deftest org-image-resize-command-saves-edge-drags-and-delegates-other-clicks ()
  (org-image-resize-test-with-drag
    (save-window-excursion
      (set-window-buffer (selected-window) (current-buffer))
      (overlay-put overlay 'org-image-overlay t)
      (let ((x 195) fallback refreshed)
        (cl-letf (((symbol-function 'image-size) (lambda (&rest _) '(200 . 100)))
                  ((symbol-function 'posn-object-x-y) (lambda (_) (cons x 20)))
                  ((symbol-function 'my-org-image-resize--track) (lambda (&rest _) 300))
                  ((symbol-function 'mouse-drag-region) (lambda (_) (setq fallback t)))
                  ((symbol-function 'org-display-inline-images)
                   (lambda (&rest _) (setq refreshed t))))
          (my-org-image-resize-drag down)
          (should refreshed)
          (should-not fallback)
          (should (equal (buffer-string)
                         "#+ATTR_ORG: :width 300\n[[file:example.png]]\n"))
          (let ((text (buffer-string)))
            (setq x 50)
            (my-org-image-resize-drag down)
            (should fallback)
            (should (equal (buffer-string) text))))))))

(ert-deftest org-image-resize-undo-refreshes-the-display ()
  (org-image-resize-test-with-drag
    (let ((org-inline-image-overlays (list overlay))
          (this-command 'evil-undo)
          refreshed)
      (cl-letf (((symbol-function 'org-display-inline-images)
                 (lambda (&rest _) (setq refreshed t))))
        (my-org-image-resize--after-undo)
        (should refreshed)
        (setq this-command 'forward-char refreshed nil)
        (my-org-image-resize--after-undo)
        (should-not refreshed)))))

(ert-deftest org-image-resize-hides-width-without-changing-note ()
  (org-image-resize-test-with-note "#+ATTR_ORG: :width 300\n[[file:example.png]]\n"
    (let ((image (make-overlay (point) (1- (point-max))))
          (my-org-image-resize-mode t)
          (text (buffer-string)))
      (my-org-image-resize--hide-attributes image)
      (should (equal (get-char-property (point-min) 'display) ""))
      (should (equal (buffer-string) text))
      (delete-overlay image)
      (my-org-image-resize--prune-attributes)
      (should-not (get-char-property (point-min) 'display)))))

(ert-deftest org-image-resize-attribute-hiding-leaves-captions-visible ()
  (org-image-resize-test-with-note "#+CAPTION: Example figure\n#+ATTR_ORG: :width 300\n[[file:example.png]]\n"
    (let ((image (make-overlay (point) (1- (point-max)))))
      (my-org-image-resize--hide-attributes image)
      (should-not (get-char-property (point-min) 'display))
      (goto-char (point-min))
      (forward-line)
      (should (equal (get-char-property (point) 'display) "")))))

;;; org-image-resize-test.el ends here

(ert-deftest org-image-resize-hidden-width-keeps-fontified-image-visible ()
  "Exercise real graphical redisplay: a live overlay alone is not enough."
  (skip-unless (display-graphic-p))
  (save-window-excursion
    (with-temp-buffer
      (org-mode)
      (set-window-buffer (selected-window) (current-buffer))
      (let ((org-image-actual-width nil)
            (my-org-image-resize-mode t))
        (insert (format "#+ATTR_ORG: :width 180\n[[file:%s]]\n"
                        (expand-file-name "images/splash.png" data-directory)))
        (goto-char (point-min))
        (font-lock-ensure)
        (org-display-inline-images)
        (my-org-image-resize--decorate)
        (dolist (width '(180 240 128))
          (let ((image (car org-inline-image-overlays)))
            (my-org-image-resize--save-width (overlay-start image) width))
          (org-display-inline-images nil t)
          (font-lock-ensure)
          (goto-char (point-min))
          (set-window-start (selected-window) (point-min))
          (redisplay t)
          ;; Image-size and window-text-pixel-size can report valid dimensions
          ;; for an image that is not drawn.  Hit-test the actual display glyph.
          (should (eq (car-safe (posn-object (posn-at-x-y 40 40 (selected-window))))
                      'image)))))))
