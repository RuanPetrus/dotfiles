(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(use-package emacs
  :init
  ;; Disable clutter
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1)

  ;; Startup
  (setq inhibit-startup-screen t)
  (setq initial-scratch-message nil)

  ;; Line numbers
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode 1)

  :config
  ;; Tree sitter is to much of a hasle to use, depends to much on the sytem, tree-sitter-version, emacs version.
  ;; (setq major-mode-remap-alist
        ;; '((c-mode          . c-ts-mode)
          ;; (c++-mode        . c++-ts-mode)
          ;; (python-mode     . python-ts-mode)))

  ;; Abi 14
  ;; (setq treesit-language-source-alist
      ;; '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.21.4")
        ;; (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.3")
        ;; (cuda "https://github.com/tree-sitter-grammars/tree-sitter-cuda" "v0.21.1")
  ;; (python "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")))
  
  ;; (add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.cuh\\'" . c++-ts-mode))

  ;; Theme
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-region '(bg-only no-extend))
  (setq modus-themes-region '(bg-only)
      modus-themes-paren-match '(bold intense)
      modus-themes-prompts '(bold intense)
      modus-themes-completions '((matches . (extrabold))
                                 (selection . (semibold accented))))

  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'modus-operandi-tinted t)
  (set-face-attribute 'fixed-pitch nil
                      :font "DejaVu Sans Mono"
                      :height 200)
  
  (set-face-attribute 'variable-pitch nil
                      :font "DejaVu Sans"
                      :height 200)
  
  (setq create-lockfiles nil)

  ;; Make emacs not save files in weird places
  (defvar my-config-dir (expand-file-name "~/.config/emacs/"))
  (setq backup-directory-alist
        `(("." . ,(expand-file-name "backups/" my-config-dir))))
  
  (setq auto-save-file-name-transforms
        `((".*" ,(expand-file-name "auto-saves/" my-config-dir) t)))
  
  (make-directory (expand-file-name "backups/" my-config-dir) t)
  (make-directory (expand-file-name "auto-saves/" my-config-dir) t)

  (setq custom-file
	(expand-file-name "custom.el" my-config-dir))

  (load custom-file 'noerror)
  
  :custom
  (ring-bell-function 'ignore)
  (use-dialog-box nil)
  (visible-bell nil)
  (column-number-mode t)
  
  (treesit-font-lock-level 3))

(use-package vterm
  :ensure t)

(use-package meow
 :ensure t
 :init
 (defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; My config
   '("." . find-file)
   '("f f" . project-find-file)
   '("f e" . (lambda () (interactive) (dired-at-point ".")))
   
   '("b b" . switch-to-buffer)
   '("b i" . ibuffer)
   '("b p" . previous-buffer)
   '("b n" . next-buffer)
   '("b s" . save-some-buffers)
   
   '("w q" . delete-window)
   '("w h" . windmove-left)
   '("w l" . windmove-right)
   '("w j" . windmove-down)
   '("w k" . windmove-up)
   '("w w" . split-window-horizontally)
   
   '("t t" . vterm)
   
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))
 :config
 (meow-setup)
 (meow-global-mode 1))

;;; Minibuffer completion (M-x, C-x C-f, buffers)
(fido-mode 1)
(fido-vertical-mode 1)

(setq completion-styles '(basic flex)
      completion-auto-select t
      completion-auto-help 'visible
      completions-format 'one-column
      completions-sort 'historical
      completions-max-height 20
      completion-ignore-case t
      tab-always-indent 'complete)

;;; Corfu popup completion in buffers
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)              ;; popup automatically
  (corfu-auto-delay 0.15)     ;; delay before popup
  (corfu-auto-prefix 2)       ;; chars before popup
  (corfu-cycle t)             ;; cycle candidates
  (corfu-preselect 'prompt)   ;; don't auto insert candidate
  :init
  (global-corfu-mode 1))

(use-package completion-preview
  :hook (prog-mode . completion-preview-mode))

(defun my-c-setup ()
  (c-set-style "k&r")
  (setq-local c-basic-offset 4
              tab-width 4
              indent-tabs-mode t)
  ;; Make backspace/delete handle tabs properly
  (c-toggle-auto-newline -1)
  (c-toggle-hungry-state 1))

(use-package cc-mode
  :ensure nil
  :hook ((c-mode . my-c-setup)
         (c++-mode . my-c-setup)))

;; CUDA files open as C++
(add-to-list 'auto-mode-alist '("\\.cu\\'"  . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cuh\\'" . c++-mode))
