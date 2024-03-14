;;; user-keybindings.el -*- lexical-binding: t; -*-

;; Windows bingings
(evil-define-key 'normal 'global
  (kbd "<leader>wh") 'evil-window-left
  (kbd "<leader>wl") 'evil-window-right
  (kbd "<leader>wk") 'evil-window-up
  (kbd "<leader>wj") 'evil-window-down
  (kbd "<leader>wc") 'evil-window-delete
  )

;; Buffer bindings
(evil-define-key 'normal 'global
  (kbd "<leader>bh") 'previous-buffer
  (kbd "<leader>bl") 'next-buffer
  (kbd "<leader>bi") 'ibuffer
  (kbd "<leader>bs") 'save-buffer
  (kbd "<leader>bc") 'kill-buffer-and-window
  (kbd "<leader>bf") 'consult-buffer
  )

;; Help bindings
(evil-define-key 'normal 'global
  (kbd "<leader>hi") 'consult-info
  (kbd "<leader>hh") 'apropos
  (kbd "<leader>hf") 'describe-function
  (kbd "<leader>hv") 'describe-variable
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
  (kbd "<leader>fc") 'goto-config-file
  (kbd "<leader>fe") 'dired-jump
  )

;; Emacs lisp specific
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (evil-define-key 'normal 'local
				(kbd "<leader>cb") 'eval-buffer
				(kbd "<leader>cl") 'eval-last-sexp
				(kbd "<leader>cb") 'eval-buffer
				)))

(provide 'user-keybindings)
