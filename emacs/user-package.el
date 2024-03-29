;;;; user-package.el -*- lexical-binding: t; -*-

;;; Package configuration
(require 'package)
(require 'time-date)

;; Emacs 27.x has gnu elpa as the default
;; Emacs 28.x adds the nongnu elpa to the list by default, so only
;; need to add nongnu when this isn't Emacs 28+
(when (version< emacs-version "28")
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(add-to-list 'package-archives '("stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(customize-set-variable 'package-archive-priorities
                        '(("gnu"    . 99)   ; prefer GNU packages
                          ("nongnu" . 80)   ; use non-gnu packages if
                                            ; not found in GNU elpa
                          ("stable" . 70)   ; prefer "released" versions
                                            ; from melpa
                          ("melpa"  . 0)))  ; if all else fails, get it
                                            ; from melpa
(customize-set-variable 'package-user-dir
                        (expand-file-name "elpa/" user-emacs-directory))

;; make sure the elpa/ folder exists after setting it above.
(unless (file-exists-p package-user-dir)
  (mkdir package-user-dir t))

(defvar user-package-update-days 1
  "The number of days old a package archive must be before it is
considered stale.")

(defun user-package-archive-stale-p (archive)
  "Return `t' if ARCHIVE is stale."
  (let* ((today (decode-time nil nil t))
         (archive-name (expand-file-name
                        (format "archives/%s/archive-contents" archive)
                        package-user-dir))
         (last-update-time (decode-time (file-attribute-modification-time
                                         (file-attributes archive-name))))
         (delta (make-decoded-time :day user-package-update-days)))
    
        (time-less-p (encode-time (decoded-time-add last-update-time delta))
                     (encode-time today))))

(defun user-package-archives-stale-p ()
  "Return `t' if any PACKAGE-ARHIVES cache is out of date."
  (interactive)
  (cl-some #'user-package-archive-stale-p (mapcar #'car package-archives)))

(defmacro user-package-install-package (package)
  "Only install pakage if it is not already installed."
  `(unless (package-installed-p ,package) (package-install ,package)))

(defmacro user-package-installed-p (package)
  ´(package-installed-p ,package))

(defun user-package-initialize ()
  "Initialize the package system."
  (progn
    (package-initialize)
    (require 'seq)
    (cond ((seq-empty-p package-archive-contents)
           (progn
             (message "package-init: package archives empty, initializing")
             (package-refresh-contents)))
          ((user-package-archives-stale-p)
           (progn
             (message "package-init: package archives stale, refreshing in the background")
             (package-refresh-contents t))))))

(provide 'user-package)

;;; user-package.el ends here
