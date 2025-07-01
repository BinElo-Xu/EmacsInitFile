;; ====================
;; Vim 用户专属 Emacs 配置 (修复版)
;; 保存为 ~/.emacs.d/init.el
;; ====================

;; 禁用默认界面元素
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;; 设置包管理器
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; 自动安装 use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; 核心 Vim 模拟配置
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; 解决 ESC 延迟
  (define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)

  ;; Vim 风格命令
  (evil-ex-define-cmd "w" 'save-buffer)
  (evil-ex-define-cmd "q" 'kill-this-buffer)
  (evil-ex-define-cmd "wq" (lambda ()
                             (interactive)
                             (save-buffer)
                             (kill-this-buffer))))

;; 扩展键位支持
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; 文件树
(use-package treemacs
  :ensure t
  :config
  (setq treemacs-width 30)
  (evil-define-key 'normal global-map (kbd "<leader>ft") 'treemacs))

;; 文件搜索
(use-package counsel
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (evil-define-key 'normal global-map (kbd "<leader>ff") 'counsel-find-file))

;; 语法检查
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; 自动补全
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 2))

;; 主题
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-dracula t)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

;; 状态栏
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; 通用设置
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4
 truncate-lines t
 show-trailing-whitespace t
 make-backup-files nil)

;; 显示设置
(global-display-line-numbers-mode 1)
(column-number-mode t)
(blink-cursor-mode 0)

;; Vim 风格快捷键
(evil-set-leader 'normal (kbd "SPC"))
(evil-define-key 'normal global-map (kbd "<leader>w") 'save-buffer)
(evil-define-key 'normal global-map (kbd "<leader>q") 'kill-this-buffer)
(evil-define-key 'normal global-map (kbd "gf") 'find-file-at-point)
(evil-define-key 'normal global-map (kbd "gb") 'counsel-switch-buffer)

;; 剪贴板支持
(setq select-enable-clipboard t)
(setq save-interprogram-paste-before-kill t)

;; 快速编辑配置文件
(defun open-init-file ()
  "打开 Emacs 配置文件"
  (interactive)
  (find-file user-init-file))
(evil-define-key 'normal global-map (kbd "<leader>ec") 'open-init-file)

;; 保存时清理空格
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; 错误处理钩子
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs 配置加载完成! 使用 <leader>ec 编辑配置")))

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
