;;; user-langs.el -*- lexical-binding: t; -*-

(add-hook 'c-mode-common-hook
          (lambda () 
            (setq c-indentation-style "k&r"
                  c-basic-offset 4)
            (setq-default tab-width 4
                          indent-tabs-mode t)))
(provide 'user-langs)
