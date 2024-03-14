;;; user-dired.el -*- lexical-binding: t; -*-

(user-package-install-package 'all-the-icons-dired)

(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(setq dired-guess-shell-alist-user
      '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open")
        ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open")
		(".*" "xdg-open")))

(provide 'user-dired)
