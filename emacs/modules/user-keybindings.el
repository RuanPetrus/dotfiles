;;; user-keybindings.el -*- lexical-binding: t; -*-

;; Install dependencies
(user-package-install-package 'evil)
(user-package-install-package 'evil-collection)
(user-package-install-package 'evil-nerd-commenter)

;; Turn on undo-tree globally
(when (< emacs-major-version 28)
  (crafted-package-install-package 'undo-tree)
  (global-undo-tree-mode))

;; Set some variables that must be configured before loading the package
(customize-set-variable 'evil-want-integration t)
(customize-set-variable 'evil-want-keybinding nil)
(customize-set-variable 'evil-want-C-i-jump nil)
(customize-set-variable 'evil-respect-visual-line-mode t)

(if (< emacs-major-version 28)
  (customize-set-variable 'evil-undo-system 'undo-tree)
  (customize-set-variable 'evil-undo-system 'undo-redo))

(customize-set-variable 'evil-want-Y-yank-to-eol t)
(customize-set-variable 'evil-want-fine-undo t)

;; Load Evil and enable it globally
(require 'evil)
(evil-mode 1)

;; Make evil search more like vim
(evil-select-search-module 'evil-search-module 'evil-search)

;; Turn on Evil Nerd Commenter
(evilnc-default-hotkeys)

;; Rebind `universal-argument' to 'C-M-u' since 'C-u' now scrolls the buffer
(global-set-key (kbd "C-M-u") 'universal-argument)

;; Use visual line motions even outside of visual-line-mode buffers
(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)

;; Make sure some modes start in Emacs state
;; TODO: Split this out to other configuration modules?
(dolist (mode '(custom-mode
                eshell-mode
                term-mode))
  (add-to-list 'evil-emacs-state-modes mode))

(evil-collection-init)


;; My keybindings
(evil-set-leader 'normal (kbd "SPC"))

;; Window navigation
(evil-define-key 'normal 'global
  (kbd "C-h") 'evil-window-left
  (kbd "C-l") 'evil-window-right
  (kbd "C-k") 'evil-window-up
  (kbd "C-j") 'evil-window-down
  (kbd "C-w c") 'evil-window-delete

  (kbd "<leader>wh") 'evil-window-left
  (kbd "<leader>wl") 'evil-window-right
  (kbd "<leader>wk") 'evil-window-up
  (kbd "<leader>wj") 'evil-window-down
  (kbd "<leader>wc") 'evil-window-delete
)

;; Buffer navigation
(evil-define-key 'normal 'global
  (kbd "H") 'previous-buffer
  (kbd "L") 'next-buffer

  (kbd "<leader>bi") 'ibuffer
)

;; Search
(evil-define-key 'normal 'global
  (kbd "<leader>sh") 'evil-ex-nohighlight
)

(defun goto-config-file () 
  "Goto user config file"
  (interactive)
  (find-file config-file))

;; File navigation
(evil-define-key 'normal 'global
  (kbd "<leader>ff") 'find-file
  (kbd "<leader>fp") 'goto-config-file
)

(provide 'user-keybindings)
