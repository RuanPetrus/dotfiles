;;; user-ui.el -*- lexical-binding: t; -*-

;; Cursor Shape
(user-package-install-package 'evil-terminal-cursor-changer)
(unless (display-graphic-p)
        (require 'evil-terminal-cursor-changer)
        (evil-terminal-cursor-changer-activate))

(customize-set-variable 'evil-motion-state-cursor 'box)
(customize-set-variable 'evil-visual-state-cursor 'box)
(customize-set-variable 'evil-normal-state-cursor 'box)
(customize-set-variable 'evil-insert-state-cursor 'bar)
(customize-set-variable 'evil-emacs-state-cursor  'hbar)


(provide 'user-ui)
