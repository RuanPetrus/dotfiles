;;; user-completion.el -*- lexical-binding: t; -*-

(user-package-install-package 'marginalia)
(user-package-install-package 'orderless)
(user-package-install-package 'vertico)
(user-package-install-package 'consult)

(defun user-completion/minibuffer-backward-kill (arg)
  "Delete word or delete up to parent folder when completion is a file.

ARG is the thing being completed in the minibuffer."
  (interactive "p")
  (if minibuffer-completing-file-name
      (if (string-match-p "/." (minibuffer-contents))
          (zap-up-to-char (- arg) ?/)
          (delete-minibuffer-contents))
      (backward-kill-word arg)))

;;; Vertico
(require 'vertico)
(require 'vertico-directory)

(with-eval-after-load 'evil
  (define-key vertico-map (kbd "C-j")

              'vertico-next)
  (define-key vertico-map (kbd "C-k") 'vertico-previous)
  (define-key vertico-map (kbd "C-h") 'vertico-directory-up))

;; Cycle back to top/bottom result when the edge is reached
(customize-set-variable 'vertico-cycle t)

;; Start Vertico
(vertico-mode 1)

;; Enable to use full system path
(file-name-shadow-mode 1)
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

;;; Marginalia
(require 'marginalia)
(customize-set-variable 'marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
(marginalia-mode 1)

;;; Orderless
;; Set up Orderless for better fuzzy matching
(require 'orderless)
(customize-set-variable 'completion-styles '(orderless basic))
(customize-set-variable 'completion-category-overrides '((file (styles . (partial-completion)))))

(provide 'user-completion)
;;; user-completion.el ends here
