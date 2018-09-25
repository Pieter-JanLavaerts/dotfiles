;;; Emacs -- editor
;;; Commentary:
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;;; Code:
(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;;ERC
(require 'erc-services)
(erc-services-mode 1)
(setq erc-prompt-for-nickserv-password nil)
(setq erc-nickserv-passwords
      '((freenode     (("hackyhacker" . "Luster3140")))))

;;Disable join, part and quit for lurkers
(setq erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
(setq erc-lurker-threshold-time 3600)

;;use-package
(require 'use-package)

;;evil mode
(require 'evil)
(evil-mode 1)
;;aangepast met customize mode
;;(setq evil-default-state "emacs")

;;toolbar
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;;ask when closing
(setq confirm-kill-emacs 'y-or-n-p)

;;shortcut for init file
(global-set-key (kbd "C-c I") (lambda () (interactive) (find-file user-init-file)))

;;Nov-mode
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;;Org-mode
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(add-hook 'org-journal-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-s") 'org-schedule)))

;;web mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode) '("\\.html\\'" . web-mode))

;;company mode
(add-hook 'after-init-hook 'global-company-mode)
(defun complete-or-indent ()
  "Complete or indent function for company mode."
  (interactive)
  (if (company-manual-begin)
      (company-complete-common)
    (indent-according-to-mode)))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "C-n") (lambda () (interactive) (company-complete-common-or-cycle 1)))
  (define-key company-active-map (kbd "C-p") (lambda () (interactive) (company-complete-common-or-cycle -1))))

;;; haskell
;; interactive haskell
(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

;; company
(require 'company)                                   ; load company mode

;; company ghci
(require 'company-ghci)
(push 'company-ghci company-backends)
(add-hook 'haskell-mode-hook 'company-mode)
;;; To get completions in the REPL
(add-hook 'haskell-interactive-mode-hook 'company-mode)

;;;;web-mode

;;company web
(require 'company-web-html)                          ; load company mode html backend
(add-hook 'web-mode-hook
	  (lambda() (add-to-list 'company-backends 'company-web-html)))

;; (setq company-minimum-prefix-length 0)            ; WARNING, probably you will get perfomance issue if min len is 0!
(setq company-tooltip-limit 20)                      ; bigger popup window
(setq company-tooltip-align-annotations 't)          ; align annotations to the right tooltip border
(setq company-idle-delay .3)                         ; decrease delay before autocompletion popup shows
(setq company-begin-commands '(self-insert-command)) ; start autocompletion only after typing
(global-set-key (kbd "C-c /") 'company-files)        ; Force complete file names on "C-c /" key

;;company jedi
(defun my/python-mode-hook ()
  "Hook for 'company-mode'."
  (add-to-list 'company-backends 'company-jedi))

(add-hook 'python-mode-hook 'my/python-mode-hook)

;;TRAMP mode
(setq tramp-default-method "ssh")

;;helm
(require 'helm-config)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-x b") 'helm-buffers-list)

;;flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;pycheckers flycheck
(require 'flycheck-pycheckers)
(with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup))

;;irony-mode
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
;;irony company mode
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  "The irony mode hook."
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))

;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)

;;irony flycheck-mode
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
(defun irony--check-expansion ()
  "Irony check expansion."
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "->") t nil)))))
(defun irony--indent-or-complete ()
  "Indent or Complete."
  (interactive)
  (cond ((and (not (use-region-p))
              (irony--check-expansion))
         (message "complete")
         (company-complete-common))
        (t
         (message "indent")
         (call-interactively 'c-indent-line-or-region))))
(defun irony-mode-keys ()
  "Modify keymaps used by `irony-mode'."
  (local-set-key (kbd "TAB") 'irony--indent-or-complete)
  (local-set-key [tab] 'irony--indent-or-complete))
(add-hook 'c-mode-common-hook 'irony-mode-keys)

;; arduino company
;; Add arduino's include options to irony-mode's variable.
;;(add-hook 'irony-mode-hook 'company-arduino-turn-on)
  
;; company-irony-c-headers in plaats van company-c-headers

(require 'company-irony-c-headers)
;; Load with `irony-mode` as a grouped backend
(eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))

;; Configuration for company-c-headers.el
(add-to-list 'company-backends 'company-c-headers)

;;;; The `company-arduino-append-include-dirs' function appends
;;;; Arduino's include directories to the default directories
;;;; if `default-directory' is inside `company-arduino-home'. Otherwise
;;;; just returns the default directories.
;;;; Please change the default include directories accordingly.
;;(defun my-company-c-headers-get-system-path ()
;;  "Return the system include path for the current buffer."
;;  (let (default '("/usr/include/" "/usr/local/include/")))
;;    (company-arduino-append-include-dirs default t))
;;
;;(setq company-c-headers-path-system 'my-company-c-headers-get-system-path)

(add-to-list 'irony-supported-major-modes 'arduino-mode)
(add-to-list 'irony-lang-compile-option-alist '(arduino-mode . "c++"))

;; Activate irony-mode on arduino-mode
(add-hook 'arduino-mode-hook 'irony-mode)

;;auctex
(load "~/.emacs.d/elpa/auctex-12.1.1/auctex.el" nil t t)
(load "~/.emacs.d/elpa/auctex-12.1.1/preview.el" nil t t)

;;EXWM
;(require 'exwm)
;(require 'exwm-config)
;(exwm-config-default)

;;qt-pro-mode
(use-package qt-pro-mode
  :ensure t
  :mode ("\\.pro\\'" "\\.pri\\'"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doc-view-resolution 300)
 '(evil-default-state (quote emacs))
 '(org-agenda-files
   (quote
    ("~/.emacs.d/Org-mode/goals.org" "~/Documents/journal/20180531" "~/.emacs.d/Org-mode/examens.org" "~/Documents/journal/20180530" "~/.emacs.d/Org-mode/habits.org")))
 '(org-modules
   (quote
    (org-bbdb org-bibtex org-docview org-gnus org-habit org-info org-irc org-mhe org-rmail org-w3m)))
 '(package-selected-packages
   (quote
    (company-ghci eclim company-ghc flycheck-haskell haskell-mode exwm nov org-journal djvu irony w3m w3 flycheck-pycheckers company-jedi qt-pro-mode flycheck-irony use-package company-irony-c-headers company-web company-auctex auctex px company-math latex-math-preview latex-pretty-symbols latex-preview-pane company-arduino flycheck arduino-mode helm web-mode company evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
