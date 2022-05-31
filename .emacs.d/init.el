;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive
(setq comp-async-report-warnings-errors nil)

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

(make-directory (expand-file-name "tmp/auto-saves/" user-emacs-directory) t)

(setq auto-save-list-file-prefix
      (expand-file-name "tmp/auto-saves/sessions/"
                        user-emacs-directory)
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "tmp/auto-saves/"
                                 user-emacs-directory) t)))

(use-package no-littering)

(set-default-coding-systems 'utf-8)

(server-start)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :config
  (general-create-definer jd/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :ensure t
  :after evil
  :init
  (evil-collection-init))

(use-package command-log-mode)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(setq visible-bell t)
;; (global-hl-line-mode t)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(setq use-dialog-box nil) ;; Disable dialog boxes since they weren't working in Mac OSX

(set-frame-parameter (selected-frame) 'alpha '(90 . 85))
(add-to-list 'default-frame-alist '(alpha . (90 . 85)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(setq-default truncate-lines t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                neotree-mode-hook
                term-mode-hook
                vterm-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq large-file-warning-threshold nil)

(setq vc-follow-symlinks t)

(setq ad-redefinition-action 'accept)

(use-package doom-themes
  :init (load-theme 'doom-one t))

(defvar jd/default-font-size 120)
(defvar jd/default-variable-font-size 120)

(defun jd/set-font-faces ()
  (message "Setting faces!")
  (set-face-attribute 'default nil
                      :font "JetBrains Mono"
                      :height jd/default-font-size
                      :weight 'light)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil
                      :font "JetBrains Mono"
                      :height jd/default-font-size
                      :weight 'light)

  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil
                      :font "Iosevka Aile"
                      :height jd/default-variable-font-size
                      :weight 'light))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook
              (lambda (frame)
                (setq doom-modeline-icon t)
                (with-selected-frame frame
                  (jd/set-font-faces))))
  (jd/set-font-faces))

(use-package emojify
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(setq display-time-format "%l:%M %p %b %y"
      display-time-default-load-average nil)

(use-package diminish)

;; You must run (all-the-icons-install-fonts) one time after
;; installing this package!

(use-package all-the-icons)

(use-package minions
  :hook (doom-modeline-mode . minions-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-lsp t)
  (doom-modeline-github t)
  (doom-modeline-minor-modes nil)
  (doom-modeline-persp-name nil)
  (doom-modeline-major-mode-icon t))

;;(display-battery-mode 1)
;;(setq display-time-day-and-date t)
;;(display-time-mode 1)

(use-package super-save
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

;; Revert buffers when the underlying files has changed
(global-auto-revert-mode 1)

(jd/leader-keys
  "."   '(find-file :which-key "find file")
  "RET" '(bookmark-view-open :which-key "show bookmarks")
  "SPC" '(neotree-toggle :which-key "toggle neotree window")

  "b"   '(:ignore t :which-key "buffer")
  "bb"  '(switch-to-buffer :which-key "show buffer")
  "bi"  '(ibuffer :which-key "show ibuffer")
  "bk"  '(kill-this-buffer :which-key "kill buffer")
  "bm"  '(bookmark-view-save :which-key "set bookmark")

  "c"   '(:ignore t :which-key "code")
  "cc"  '(compile :which-key "compile code")
  "ct"  '(org-babel-tangle :which-key "write code blocks")

  "f"   '(:ignore t :which-key "file")
  "fR"  '(delete-file :which-key "delete file")

  "g"   '(:ignore t :which-key "magit")
  "gg"  '(magit :which-key "show status")
  "gi"  '(magit-init :which-key "git init")
  "gc"  '(magit-clone :which-key "git clone")

  "ot"  '(vterm-toggle :which-key "launch vterm")
  "ol"  '(display-line-numbers-mode :which-key "display line numbers")
  "op"  '(org-present :which-key "org-mode presentation")
  "oi"  '(org-toggle-inline-images :which-key "display images in org-mode")
  "on"  '(jd/search-org-files :which-key "show notes")

  "t"   '(:ignore t :which-key "toggles")
  "tt"  '(counsel-load-theme :which-key "choose theme"))

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a"))

(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package ws-butler
  :hook ((text-mode . ws-butler-mode)
         (prog-mode . ws-butler-mode)))

(use-package neotree)
(setq neo-smart-open t
      neo-window-fixed-size nil)

(use-package hydra
  :defer 1)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-hydra
  :defer t
  :after hydra)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1))

(defun jd/minibuffer-backward-kill (arg)
  "When minibuffer is completing a file name delete up to parent
folder, otherwise delete a word"
  (interactive "p")
  (if minibuffer-completing-file-name
      ;; Borrowed from https://github.com/raxod502/selectrum/issues/498#issuecomment-803283608
      (if (string-match-p "/." (minibuffer-contents))
          (zap-up-to-char (- arg) ?/)
        (delete-minibuffer-contents))
      (backward-kill-word arg)))

(use-package vertico
  :bind (:map vertico-map
         ("C-j" . vertico-next)
         ("C-k" . vertico-previous)
         ("C-f" . vertico-exit)
         :map minibuffer-local-map
         ("M-h" . jd/minibuffer-backward-kill))
  :custom
  (vertico-cycle t)
  :custom-face
  (vertico-current ((t (:background "#3a3f5a"))))
  :init
  (vertico-mode))

(use-package corfu
  :bind (:map corfu-map
         ("C-j" . corfu-next)
         ("C-k" . corfu-previous)
         ("C-f" . corfu-insert))
  :custom
  (corfu-cycle t)
  :config
  (corfu-global-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(defun jd/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-project-root)))

(use-package consult
  :demand t
  :bind (("C-s" . consult-line)
         ("C-M-l" . consult-imenu)
         ("C-r" . consult-history))
  :custom
  (consult-project-root-function #'jd/get-project-root)
  (completion-in-region-function #'consult-completion-in-region))

(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
   ("<tab>" . company-indent-or-complete-common))
  :custom
  (comapany-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(add-hook 'after-init-hook 'global-company-mode)

(defun jd/org-mode-visual-fill()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :defer t
  :hook (org-mode . jd/org-mode-visual-fill))

(setq display-buffer-base-action
      '(display-buffer-reuse-mode-window
        display-buffer-reuse-window
        display-buffer-same-window))

;; If a popup does happen, don't resize windows to be equal-sized
(setq even-window-sizes nil)

(use-package all-the-icons-dired)

(use-package dired
  :ensure nil
  :defer 1
  :commands (dired dired-jump)
  :config
  (setq dired-listing-switches "-agho --group-directories-first"
        dired-omit-files "^\\.[^.].*"
        dired-omit-verbose nil
        dired-hide-details-hide-symlink-targets nil
        delete-by-moving-to-trash t)

  (autoload 'dired-omit-mode "dired-x")

  (add-hook 'dired-load-hook
            (lambda ()
              (interactive)
              (dired-collapse)))

  (add-hook 'dired-mode-hook
            (lambda ()
              (interactive)
              (dired-omit-mode 1)
              (dired-hide-details-mode 1)
              (hl-line-mode 1)))

  (use-package dired-rainbow
    :defer 2
    :config
    (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
    (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
    (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
    (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
    (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
    (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
    (dired-rainbow-define media "#de751f" ("mp3" "mp4" "mkv" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
    (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
    (dired-rainbow-define log "#c17d11" ("log"))
    (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
    (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
    (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
    (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
    (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
    (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
    (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
    (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
    (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
    (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
    (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

  (use-package dired-single
    :defer t)

  (use-package dired-ranger
    :defer t)

  (use-package dired-collapse
    :defer t)

  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "H" 'dired-omit-mode
    "l" 'dired-single-buffer
    "y" 'dired-ranger-copy
    "X" 'dired-ranger-move
    "p" 'dired-ranger-paste))

(use-package openwith
  :defer t
  :config
  (setq openwith-associations
        (list
          (list (openwith-make-extension-regexp
                '("mpg" "mpeg" "mp3" "mp4"
                  "avi" "wmv" "wav" "mov" "flv"
                  "ogm" "ogg" "mkv" "opus"))
                "mpv"
                '(file))
          (list (openwith-make-extension-regexp
                '("xbm" "pbm" "pgm" "ppm" "pnm"
                  "png" "gif" "bmp" "tif" "jpg"))
                  "sxiv"
                  '(file))
          (list (openwith-make-extension-regexp
                '("pdf"))
                "zathura"
                '(file)))))

(use-package bookmark-view)

(setq-default fill-column 80)

(use-package simple-httpd
	:ensure t)

(defun jd/org-mode-setup ()
	(org-indent-mode)
	(variable-pitch-mode 1)
	(auto-fill-mode 0)
	(visual-line-mode 1)
	(setq evil-auto-indent nil)
	(diminish org-indent-mode))

(use-package org
	:defer t
	:hook (org-mode . jd/org-mode-setup)
	:config
	(setq org-ellipsis "..."
				org-hide-emphasis-markers t
				org-src-fontify-natively t
				org-fontify-quote-and-verse-blocks nil
				org-src-tab-acts-natively t
				org-edit-src-content-indentation 2
				org-hide-block-startup nil
				org-src-preserve-indentation nil
				org-startup-folded 'content
				org-cycle-separator-lines 2)

	(setq org-modules
				'(org-crypt
					org-habit
					org-bookmark
					org-eshell
					org-irc))
	(setq org-refile-targets '((nil :maxlevel . 1)
														 (org-agenda-files :maxlevel . 1)))

	(setq org-outline-path-complete-in-steps nil)
	(setq org-refiles-use-outline-path t)

	(evil-define-key '(normal insert visual) org-mode-map (kbd "C-j") 'org-next-visible-heading)
	(evil-define-key '(normal insert visual) org-mode-map (kbd "C-k") 'org-previous-visible-heading)

	(evil-define-key '(normal insert visual) org-mode-map (kbd "M-j") 'org-metadown)
	(evil-define-key '(normal insert visual) org-mode-map (kbd "M-k") 'org-metaup)

	(org-babel-do-load-languages
	 'org-babel-load-languages
	 '((emacs-lisp . t)))

	(push '("conf-unix" . conf-unix) org-src-lang-modes)

	(use-package org-superstar
		:after org
		:hook (org-mode . org-superstar-mode)
		:custom
		(org-directory "~/Repo/notes")
		(org-superstar-remove-leading-stars t)
		;; (org-ellipsis "...")
		(org-superstar-item-bullet-alist '((?+ . ?✦) (?- . ?)))
		(org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

	;; Increase the size of various headings
	(set-face-attribute 'org-document-title nil :font "Iosevka Aile" :weight 'bold :height 1.3)
	(dolist (face '((org-level-1 . 1.4)
									(org-level-2 . 1.3)
									(org-level-3 . 1.2)
									(org-level-4 . 1.1)
									(org-level-5 . 1.05)
									(org-level-6 . 1.05)
									(org-level-7 . 1.05)
									(org-level-8 . 1.05)))
	(set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'medium :height (cdr face)))

	(require 'org-indent)
	(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
	(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
	(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
	(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
	(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
	(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
	(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
	(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
	(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

	;; Get rid of the background on column views
	(set-face-attribute 'org-column nil :background nil)
	(set-face-attribute 'org-column-title nil :background nil))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("src" . "src"))
(add-to-list 'org-structure-template-alist '("sh" . "src sh"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("java" . "src java"))
(add-to-list 'org-structure-template-alist '("xml" . "src xml"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(defun jd/search-org-files ()
  (interactive)
  (counsel-rg "" "~/Repo/org-book/" nil "Search Notes: "))

(defun jd/org-present-prepare-slide ()
  (org-overview)
  (org-show-entry)
  (org-show-subtree)
  (org-show-children))

(defun jd/org-present-hook ()
  (setq-local face-remapping-alist '((default (:height 1.3) variable-pitch)
                                     (header-line (:height 4.5) variable-pitch)
                                     (org-code (:height 1.3) org-code)
                                     (org-verbatim (:height 1.3) org-verbatim)
                                     (org-block (:height 1.25) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))
  (setq header-line-format " ")
  (org-display-inline-images)
  (jd/org-present-prepare-slide))

(defun jd/org-present-quit-hook ()
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil)
  (org-present-small)
  (org-remove-inline-images))

(defun jd/org-present-prev ()
  (interactive)
  (org-present-prev)
  (jd/org-present-prepare-slide))

(defun jd/org-present-next ()
  (interactive)
  (org-present-next)
  (jd/org-present-prepare-slide))

(use-package org-present
  :bind (:map org-present-mode-keymap
         ("C-c C-j" . jd/org-present-next)
         ("C-c C-k" . jd/org-present-prev))
  :hook ((org-present-mode . jd/org-present-hook)
         (org-present-mode-quit . jd/org-present-quit-hook)))

(use-package ox-reveal)

(use-package org-appear
  :hook (org-mode . org-appear-mode))

(use-package magit
  :ensure t
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package lsp-mode
  :ensure t
  :commands lsp
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-completion-enable-additional-text-edit nil))

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-sideline-enable t)
  (setq lsp-ui-sideline-show-hover t)
  (setq lsp-ui-doc-position 'bottom))

(use-package dap-mode
  :after lsp-mode
  :ensure t
  :custom
  (lsp-enable-dap-auto-configure nil)
  :config
  (dap-auto-configure-mode)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (require 'dap-node)
  (dap-node-setup))

(use-package lispy
  :hook ((emacs-lisp-mode . lispy-mode)
         (scheme-mode . lispy-mode)))

;; (use-package evil-lispy
;;   :hook ((lispy-mode . evil-lispy-mode)))

(use-package lispyville
  :hook ((lispy-mode . lispyville-mode))
  :config
  (lispyville-set-key-theme '(operators c-w additional
                              additional-movement slurp/barf-cp
                              prettify)))

(use-package cider
  :mode "\\.clj[sc]?\\'"
  :config
  (evil-collection-cider-setup))

(use-package nvm
  :defer t)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

(defun jd/set-js-indentation ()
  (setq js-indent-level 2)
  (setq evil-shift-width js-indent-level)
  (setq-default tab-width 2))

(use-package js2-mode
  :mode "\\.jsx?\\'"
  :config
  ;; Use js2-mode for Node scripts
  (add-to-list 'magic-mode-alist '("#!/usr/bin/env node" . js2-mode))

  ;; Don't use built-in syntax checking
  (setq js2-mode-show-strict-warnings nil)

  ;; Set up proper indentation in JavaScript and JSON files
  (add-hook 'js2-mode-hook #'jd/set-js-indentation)
  (add-hook 'json-mode-hook #'jd/set-js-indentation))

(use-package apheleia
  :config
  (apheleia-global-mode +1))

(use-package prettier-js
:hook ((js2-mode . prettier-js-mode)
       (typescript-mode . prettier-js-mode))
:config
(setq prettier-js-show-errors nil))

(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))

(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(jd/leader-keys
  "e"   '(:ignore t :which-key "eval")
  "eb"  '(eval-buffer :which-key "eval buffer"))

(jd/leader-keys
  :keymaps '(visual)
  "er" '(eval-region :which-key "eval region"))

(use-package markdown-mode
  :mode "\\.md\\'"
  :config
  (setq markdown-command "marked")
  (defun jd/set-markdown-header-font-sizes ()
    (dolist (face '((markdown-header-face-1 . 1.2)
                    (markdown-header-face-2 . 1.1)
                    (markdown-header-face-3 . 1.0)
                    (markdown-header-face-4 . 1.0)
                    (markdown-header-face-5 . 1.0)))
      (set-face-attribute (car face) nil :weight 'normal :height (cdr face))))

  (defun jd/markdown-mode-hook ()
    (jd/set-markdown-header-font-sizes))

  (add-hook 'markdown-mode-hook 'jd/markdown-mode-hook))

(use-package web-mode
  :mode "(\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'"
  :config
  (setq-default web-mode-code-indent-offset 2)
  (setq-default web-mode-markup-indent-offset 2)
  (setq-default web-mode-attribute-indent-offset 2))

(use-package ac-html
  :config
  (ac-start t))
(use-package lorem-ipsum)

;; 1. Start the server with `httpd-start'
;; 2. Use `impatient-mode' on any buffer
(use-package impatient-mode)

(use-package skewer-mode)
(use-package prettier
  :config
  (prettier-mode t))

(use-package lsp-java
  :config (add-hook 'java-mode-hook 'lsp))

(use-package compile
  :custom
  (compilation-scroll-output t))

(defun auto-recompile-buffer ()
  (interactive)
  (if (member #'recompile after-save-hook)
      (remove-hook 'after-save-hook #'recompile t)
    (add-hook 'after-save-hook #'recompile nil t)))

(use-package flycheck
  :defer t
  :hook (lsp-mode . flycheck-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (setq yas-snippet-dirs '("~/Repo/snippets"))
  (yas-global-mode 1))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         web-mode
         typescript-mode
         js2-mode))

(use-package highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'bitmap)

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle)

(use-package emms
  :commands emms
  :config
  (require 'emms-setup)
  (emms-standard)
  (emms-default-players)
  (emms-mode-line-disable)
  (setq emms-source-file-default-directory "~/Music/")
  (jd/leader-keys
    "am"  '(:ignore t :which-key "media")
    "amp" '(emms-pause :which-key "play / pause")
    "amf" '(emms-play-file :which-key "play file")))

(use-package daemons
  :commands daemons)

(use-package sudo-edit)
