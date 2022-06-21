(defun jd/run-in-background (command)
  (let ((command-parts (split-string command "[ ]+")))
    (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(defvar jd/sxhkd-process nil)
(defun jd/run-sxhkd ()
  (interactive)
  (setq jd/sxhkd-process
        (start-process-shell-command
         "sxhkd" nil "sxhkd -c ~/.emacs.d/exwm/sxhkdrc")))

(defun jd/update-wallpaper ()
  (interactive)
  (start-process-shell-command
   "nitrogen" nil
   (format "nitrogen --set-scaled ~/.emacs.d/exwm/wallpaper.jpg")))

(defun jd/exwm-init-hook ()
  (exwm-workspace-switch-create 1)
  (jd/update-wallpaper)
  (jd/run-sxhkd)
  (jd/start-panel))

(defun jd/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun jd/exwm-update-title ()
  (pcase exwm-class-name
		("Brave-browser" (exwm-workspace-rename-buffer (format "brave: %s" exwm-title)))
    ("Vimb" (exwm-workspace-rename-buffer (format "vimb: %s" exwm-title)))
    ("qutebrowser" (exwm-workspace-rename-buffer (format "qutebrowser: %s" exwm-title)))))

(defun jd/configure-window-by-class ()
  (interactive)
  (pcase exwm-class-name
	 ("Brave-browser" (exwm-workspace-move-window 2))
   ("Vimb" (exwm-workspace-move-window 2))
   ("qutebrowser" (exwm-workspace-move-window 2))
   ("mpv" (exwm-floating-toggle-floating)
          (exwm-layout-toggle-mode-line))
   ("sxiv" (exwm-floating-toggle-floating)
          (exwm-layout-toggle-mode-line))))

(use-package exwm
  :config
  (setq exwm-workspace-number 5)
  (add-hook 'exwm-update-class-hook #'jd/exwm-update-class)
  (add-hook 'exwm-init-hook #'jd/exwm-init-hook)
  (add-hook 'exwm-update-title-hook #'jd/exwm-update-title)
  (add-hook 'exwm-manage-finish-hook #'jd/configure-window-by-class)
  (require 'exwm-randr)
  (exwm-randr-enable)
  (start-process-shell-command
   "xrandr" nil "xrandr --output eDP-1 --mode 1366x768 --pos 0x0 --rotate normal")
  ;;(require 'exwm-systemtray)
  ;;(exwm-systemtray-enable)
  (setq exwm-input-prefix-keys
    '(?\C-x
      ?\C-u
      ?\C-h
      ?\M-x
      ?\M-`
      ?\M-&
      ?\M-:
      ?\C-\M-j  ;; Buffer list
      ?\C-\ ))  ;; Ctrl+Space
  (define-key exwm-mode-map [?\C-q] `exwm-input-send-next-key)
  (setq exwm-input-global-keys
        `(
          ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
          ([?\s-r] . exwm-reset)

          ;; Exwm-keybindings
          ([?\s-f] . exwm-layout-set-fullscreen)
          ([?\s-F] . exwm-floating-toggle-floating)
          ([?\s-s] . split-window-right)
          ([?\s-S] . split-window-below)

          ;; Move between windows
          ([?\s-j] . windmove-left)
          ([?\s-k] . windmove-right)
          ([?\s-K] . windmove-up)
          ([?\s-J] . windmove-down)

          ;; Launch applications via shell command
          ([?\s-!] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))

          ;; Switch workspace
          ([?\s-w] . exwm-workspace-switch)
          ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

          ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))

  (exwm-input-set-key (kbd "s-s") 'split-window-right)
  (exwm-input-set-key (kbd "s-t") '+vterm/here)
  (exwm-input-set-key (kbd "C-M-j") 'counsel-switch-buffer)
  (exwm-input-set-key (kbd "s-q") 'kill-current-buffer)

  (exwm-enable))

;; POLYBAR
(defvar jd/polybar-process nil)

(defun jd/kill-panel ()
  (interactive )
  (when jd/polybar-process
    (ignore-errors
      (kill-process jd/polybar-process)))
  (setq jd/polybar-process nil))

(defun jd/start-panel ()
  (interactive)
  (jd/kill-panel)
  (setq jd/polybar-process (start-process-shell-command "polybar" nil "polybar panel")))

(defun jd/send-polybar-hook (module-name hook-index)
  (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

(defun jd/update-polybar-exwm ()
  (jd/send-polybar-hook "exwm-workspace" 1))

(defun jd/polybar-exwm-workspace ()
  (pcase exwm-workspace-current-index
    (0 "💀")
    (1 "🔥")
    (2 "📡")
    (3 "✨")
    (4 "💣")))

(add-hook 'exwm-workspace-switch-hook #'jd/update-polybar-exwm)
