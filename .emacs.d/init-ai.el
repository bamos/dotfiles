; (require 'gptel)
; (when (file-exists-p "~/.gptel-key")
;   (setq gptel-api-key (with-temp-buffer (insert-file-contents "~/.gptel-key") (buffer-string))))
; (when (file-exists-p "~/.gptel-key-gemini")
;    gptel-model "gemini-pro"
;    gptel-backend (gptel-make-gemini "Gemini"
;                    :key (with-temp-buffer (insert-file-contents "~/.gptel-key-gemini") (buffer-string))
;                    :stream t))

; (define-key gptel-mode-map (kbd "C-c C-c") #'gptel-send)

;; (add-to-list 'load-path "~/src/copilot.el")
(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main"))
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

(define-key global-map (kbd "<tab>") #'copilot-accept-completion)
(define-key global-map (kbd "TAB") #'copilot-accept-completion)

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


(add-to-list 'package-archives
             '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(use-package eat :ensure t)

(use-package claude-code :ensure t
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map)
  ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode)))
