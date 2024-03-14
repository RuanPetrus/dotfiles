;;; user-ui.el -*- lexical-binding: t; -*-

(user-package-install-package 'evil-terminal-cursor-changer)
(user-package-install-package 'all-the-icons)
(user-package-install-package 'modus-themes)

;; Cursor Shape
(unless (display-graphic-p)
        (require 'evil-terminal-cursor-changer)
        (evil-terminal-cursor-changer-activate))

(setq evil-motion-state-cursor 'box)
(setq evil-visual-state-cursor 'box)
(setq evil-normal-state-cursor 'box)
(setq evil-insert-state-cursor 'bar)
(setq evil-emacs-state-cursor  'hbar)

;; Theme

(require 'modus-themes)

(setq modus-themes-common-palette-overrides
      `(
        ;; From the section "Make the mode line borderless"
        (border-mode-line-active unspecified)
        (border-mode-line-inactive unspecified)

        ;; From the section "Make matching parenthesis more or less intense"
        (bg-paren-match bg-magenta-intense)
        (underline-paren-match fg-main)

        ;; And expand the preset here.  Note that the ,@ works because
        ;; we use the backtick for this list, instead of a straight
        ;; quote.
        ,@modus-themes-preset-overrides-intense))

(load-theme 'modus-vivendi-tinted t)

(provide 'user-ui)
