;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Ruan Petrus Alves Leite"
      user-mail-address "xastroboyx11@gmail.com")

(setq doom-theme 'doom-gruvbox)
(setq which-key-idle-delay 0.5) ;; I need the help, I really do
(setq display-line-numbers-type 'relative)

;; Set locale
(setq system-time-locale "en_US.UTF-8")
(setq system-messages-locale "en_US.UTF-8")
(setq woman-locale "en_US.UTF-8")

;; Better navigation
(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; Latex configuration
(setq +latex-viewers '(zathura pdf-tools evince okular skim sumatrapdf))

(map!
   :map LaTeX-mode-map
   :localleader
   :desc "View" "v" #'TeX-view)

;; Org
(setq org-directory "~/Documents/org/")


;; Agenda
(defvar my/org-custom-daily-agenda
  ;; `org-agenda-skip-function'.
  `((tags-todo "*"
               ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                (org-agenda-skip-function
                 `(org-agenda-skip-entry-if
                   'notregexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                (org-agenda-block-separator nil)
                (org-agenda-overriding-header "🤔 Important tasks without a date\n")))
    (agenda "" ((org-agenda-time-grid nil)
                (org-agenda-start-on-weekday nil)
                (org-agenda-span 1)
                (org-agenda-show-all-dates nil)
                (org-scheduled-past-days 365)
                ;; Excludes today's scheduled items
                (org-scheduled-delay-days 1)
                (org-agenda-block-separator nil)
                (org-agenda-entry-types '(:scheduled))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                (org-agenda-format-date "")
                (org-agenda-overriding-header "\n📚 Pending scheduled tasks")))
    (agenda "" ((org-agenda-start-on-weekday nil)
                (org-agenda-start-day "+0d")
                (org-agenda-span 1)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-scheduled-past-days 0)
                ;; We don't need the `org-agenda-date-today'
                ;; highlight because that only has a practical
                ;; utility in multi-day views.
                (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                (org-agenda-format-date "%A %-e %B %Y")
                (org-agenda-overriding-header "\n📌 Today's agenda\n")))
    (agenda "" ((org-agenda-start-on-weekday nil)
                (org-agenda-start-day "+1d")
                (org-agenda-span 5)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-overriding-header "\n⏰ Next three days\n")))
    (agenda "" ((org-agenda-time-grid nil)
                (org-agenda-start-on-weekday nil)
                ;; We don't want to replicate the previous section's
                ;; three days, so we start counting from the day after.
                (org-agenda-start-day "+6d")
                (org-agenda-span 14)
                (org-agenda-show-all-dates nil)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-agenda-entry-types '(:deadline))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-overriding-header "\n🕘 Upcoming deadlines (+14d)\n"))))
  "Custom agenda for use in `org-agenda-custom-commands'.")


(setq org-agenda-custom-commands
      `(("A" "Daily agenda and top priority tasks"
         ,my/org-custom-daily-agenda)
        ))

;; Denote
(setq denote-directory "~/Documents/org")

(setq denote-templates
      '((wiki . "\nlinks:\n\n*")
))

;; We use different ways to specify a path for demo purposes.
(setq denote-dired-directories
      (list denote-directory
            (thread-last denote-directory (expand-file-name "attachments"))
            (expand-file-name "~/Documents/blog")))

(add-hook 'dired-mode-hook #'denote-dired-mode-in-directories)

(defun my/denote-journal ()
  "Create an entry tagged 'journal' with the date as its title."
  (interactive)
  (denote
   (format-time-string "%A %e %B %Y") ; format like Tuesday 14 June 2022
   '("journal")
   nil
   "~/Documents/org/journal"
   ))

(defun my/denote-wiki ()
  "Create an entry tagged 'journal' with the date as its title."
  (interactive)
  (denote
   (denote-title-prompt) ; format like Tuesday 14 June 2022
   (denote-keywords-prompt)
   nil
   "~/Documents/org/wiki"
   nil
   `wiki
   ))

(defun my/denote-capture ()
  "Create an entry tagged 'journal' with the date as its title."
  (interactive)
  (denote
   (denote-title-prompt) ; format like Tuesday 14 June 2022
   (denote-keywords-prompt)
   nil
   "~/Documents/org/capture"
   nil
   `wiki
   ))

(map! :leader
       (:prefix ("n" . "notes")
        :desc "Agenda" "a" #'org-agenda
        :desc "Open or create entry" "f" #'denote-open-or-create
        :desc "New wiki entry" "w" #'my/denote-wiki
        :desc "New jornal entry" "j" #'my/denote-journal
        :desc "New capture entry" "c" #'my/denote-capture
        :desc "Add  new link" "i" #' denote-link-or-create
       ))

(defcustom my-default-image-directory
  "~/Documents/org/resources/"
  "Default directory for images for org link insertion."
  :type 'string
  :group 'image-org-link-insertion)

(defcustom my-image-extensions
  '("png" "jpg" "jpeg" "tiff")
  "List of image extensions allowed for org link insertion."
  :type '(repeat string)
  :group 'image-org-link-insertion)

(defun insert-image-org-link (img)
  "Insert an org image link, choosing the file with completion
and starting from `my-default-image-directory'."
  (interactive
   (list (read-file-name
          "Image: " my-default-image-directory nil t nil
          (lambda (name)
            (or (directory-name-p name)
                (member (file-name-extension name)
                        my-image-extensions))))))
  (insert (format "[[%s]]" img)))
