(require 'gptel)
(when (file-exists-p "~/.gptel-key")
  (setq gptel-api-key (with-temp-buffer (insert-file-contents "~/.gptel-key") (buffer-string))))
(when (file-exists-p "~/.gptel-key-gemini")
   gptel-model "gemini-pro"
   gptel-backend (gptel-make-gemini "Gemini"
                   :key (with-temp-buffer (insert-file-contents "~/.gptel-key-gemini") (buffer-string))
                   :stream t))

(define-key gptel-mode-map (kbd "C-c C-c") #'gptel-send)

(add-to-list 'load-path "~/src/copilot.el")
(require 'copilot)
; (use-package copilot
;   :quelpa (copilot.el :fetcher github
;                       :repo "zerolfx/copilot.el"
;                       :branch "main"
;                       :files ("dist" "*.el")))

(add-hook 'prog-mode-hook 'copilot-mode)

(defun copilot-tab ()
  (interactive)
  (or (copilot-accept-completion)
      (indent-for-tab-command)))

(define-key global-map (kbd "<tab>") #'copilot-tab)
(define-key global-map (kbd "TAB") #'copilot-tab)

(defun copilot-quit ()
  "Run `copilot-clear-overlay' or `keyboard-quit'. If copilot is
cleared, make sure the overlay doesn't come back too soon."
  (interactive)
  (condition-case err
      (when copilot--overlay
        (lexical-let ((pre-copilot-disable-predicates copilot-disable-predicates))
          (setq copilot-disable-predicates (list (lambda () t)))
          (copilot-clear-overlay)
          (run-with-idle-timer
           1.0
           nil
           (lambda ()
             (setq copilot-disable-predicates pre-copilot-disable-predicates)))))
    (error err)))

(advice-add 'keyboard-quit :before #'copilot-quit)
