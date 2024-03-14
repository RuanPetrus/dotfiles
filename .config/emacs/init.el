;;; init.el -*- lexical-binding: t; -*-

(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "Emacs loaded in %s"

		     (emacs-init-time))))
;;; Initializing package system
(user-package-initialize)

;; Default coding system
(set-default-coding-systems 'utf-8)
(customize-set-variable 'visible-bell 1) ;; Turn off beeps, make them flash!
(customize-set-variable 'large-file-warning-threshold 100000000) ;; Change to ~100 MB

;;   The file used by the Customization UI to store value-setting
(customize-set-variable 'custom-file
			(expand-file-name "custom.el" user-emacs-directory))


;; Default directories
(defvar user-config-var-directory    (expand-file-name "var/" user-emacs-directory))
(defvar user-config-etc-directory    (expand-file-name "etc/" user-emacs-directory))
(defvar user-config-backup-directory (expand-file-name "backup/"  user-emacs-directory))

(mkdir user-config-var-directory t)
(mkdir user-config-etc-directory t)
(mkdir user-config-backup-directory t)

;; Write backups to backup directory
(setq backup-directory-alist `(("." . ,user-config-backup-directory))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5) ; and how many of the old


(load custom-file t)

;; Modules systems
(add-to-list 'load-path (expand-file-name "modules/" user-emacs-directory))

;; Check the system used
(defconst ON-LINUX   (eq system-type 'gnu/linux))
(defconst ON-MAC     (eq system-type 'darwin))
(defconst ON-BSD     (or ON-MAC (eq system-type 'berkeley-unix)))
(defconst ON-WINDOWS (memq system-type '(cygwin windows-nt ms-dos)))

;; Use config file
(defvar config-file (expand-file-name "config.el" user-emacs-directory))
(when (file-exists-p config-file)
  (load config-file nil 'nomessage))
