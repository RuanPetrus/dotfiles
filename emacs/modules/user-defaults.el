;;; user-defaults.el -*- lexical-binding: t; -*-

;; Revert Dired and other buffers
(customize-set-variable 'global-auto-revert-non-file-buffers t)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; Typed text replaces the selection if the selection is active,
;; pressing delete or backspace deletes the selection.
(delete-selection-mode)

;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)

;; Short answers
(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (advice-add 'yes-or-no-p :override #'y-or-n-p))

;; Turn on recentf mode
(add-hook 'after-init-hook #'recentf-mode)
(customize-set-variable 'recentf-save-file
                        (expand-file-name "recentf" user-config-var-directory))

;; Do not save duplicates in kill-ring
(customize-set-variable 'kill-do-not-save-duplicates t)

;; Make scrolling less stuttered
(setq auto-window-vscroll nil)
(customize-set-variable 'fast-but-imprecise-scrolling t)
(customize-set-variable 'scroll-conservatively 101)
(customize-set-variable 'scroll-margin 0)
(customize-set-variable 'scroll-preserve-screen-position t)

;; Better support for files with long lines
(setq-default bidi-paragraph-direction 'left-to-right)
(setq-default bidi-inhibit-bpa t)
(global-so-long-mode 1)

(defun user-defaults--sensible-path
    (root varname name)
  "Sets the VARNAME to a path named NAME inside ROOT."
  (customize-set-variable varname (expand-file-name name root)))

(user-defaults--sensible-path user-config-var-directory
                              'savehist-file
                              "history")

(user-defaults--sensible-path user-config-var-directory
                              'auto-save-list-file-prefix
                              "auto-save-list/.saves-")

(with-eval-after-load 'saveplace
  (user-defaults--sensible-path user-config-var-directory
                                'save-place-file "places"))

(with-eval-after-load 'bookmark
  (user-defaults--sensible-path user-config-var-directory
                                'bookmark-default-file "bookmarks"))

(with-eval-after-load 'tramp
  (user-defaults--sensible-path user-config-var-directory
                                'tramp-persistency-file-name
                                "tramp"))

(with-eval-after-load 'org-id
  (user-defaults--sensible-path user-config-var-directory
                                'org-id-locations-file
                                "org-id-locations"))

(with-eval-after-load 'nsm
  (user-defaults--sensible-path user-config-var-directory
                                'nsm-settings-file
                                "network-security.data"))

(with-eval-after-load 'project
  (user-defaults--sensible-path user-config-var-directory
                                'project-list-file
                                "projects"))

(provide 'user-defaults)
