;;; user-evil.el -*- lexical-binding: t; -*-

;; Install dependencies

(user-package-install-package 'evil)
(user-package-install-package 'evil-collection)

;; Turn on undo-tree globally
(when (< emacs-major-version 28)
  (user-package-install-package 'undo-tree)
  (global-undo-tree-mode))

;; Set some variables that must be configured before loading the package
(customize-set-variable 'evil-want-integration t)
(customize-set-variable 'evil-want-keybinding nil)
(customize-set-variable 'evil-want-C-i-jump nil)
(customize-set-variable 'evil-want-C-u-scroll t)
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

;; Rebind `universal-argument' to 'C-M-u' since 'C-u' now scrolls the buffer
(global-set-key (kbd "C-M-u") 'universal-argument)

;; Use visual line motions even outside of visual-line-mode buffers
(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)

;; Make sure some modes start in Emacs state
;; TODO: Split this out to other configuration modules?
(dolist (mode '(custom-mode
                eshell-mode
                git-rebase-mode
                term-mode))
  (add-to-list 'evil-emacs-state-modes mode))

;; My keybindings

(evil-set-leader 'normal (kbd "SPC") t)
(evil-set-leader 'normal (kbd "SPC"))

(setq evil-collection-key-blacklist '( "SPC" ))

(evil-collection-init)

(evil-define-key 'normal 'global
  (kbd ":") 'execute-extended-command
)

;;; esc quits
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(provide 'user-evil)
