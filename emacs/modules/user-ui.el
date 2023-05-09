;;; user-ui.el -*- lexical-binding: t; -*-

(user-package-install-package 'doom-themes)
(user-package-install-package 'evil-terminal-cursor-changer)
(user-package-install-package 'all-the-icons)

;; Theme
(progn
  (disable-theme 'deeper-blue)
  (load-theme 'doom-gruvbox t))

;; Fonts
(add-hook 'emacs-startup-hook
          (lambda ()
            (custom-set-faces
             `(default ((t (:font "Hack 16"))))
             `(fixed-pitch ((t (:inherit (default)))))
             `(fixed-pitch-serif ((t (:inherit (default)))))
             `(variable-pitch ((t (:font "Overpass 16")))))))

;; Cursor Shape
(unless (display-graphic-p)
        (require 'evil-terminal-cursor-changer)
        (evil-terminal-cursor-changer-activate))

(customize-set-variable 'evil-motion-state-cursor 'box)
(customize-set-variable 'evil-visual-state-cursor 'box)
(customize-set-variable 'evil-normal-state-cursor 'box)
(customize-set-variable 'evil-insert-state-cursor 'bar)
(customize-set-variable 'evil-emacs-state-cursor  'hbar)


(provide 'user-ui)
