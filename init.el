;;; init.el --- the init file for emacs
;;; Commentary:

;; ====================
;; Vim 用户专属 Emacs 配置
;; 保存为 ~/.emacs.d/init.el
;; ====================

;;; Code:
;; -- 关闭所有声音提示 --
(setq ring-bell-function 'ignore) ; 关闭错误提示音
(setq visible-bell nil)           ; 关闭视觉提示（闪烁）

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

;; hydra插件配置
(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)

;; 核心 Vim 模拟配置
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  ;; 绑定
  (use-package key-chord
  :ensure t
  :config
  ;; 开启 key-chord-mode
  (key-chord-mode 1)
  ;; 设置超时时间（单位：秒）。0.3秒是一个不错的起点，可以根据手感调整。
  (setq key-chord-two-keys-delay 0.3)
  ;; 定义 "jj" 这个组合键，让它在 insert state 和 emacs state 下都执行 evil-normal-state
  (key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
  (key-chord-define evil-emacs-state-map "jj" 'evil-normal-state))

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

;; 文件搜索
(use-package counsel
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (evil-define-key 'normal global-map (kbd "<leader>ff") 'counsel-find-file))

;; 补全系统、部分常用命令、搜索功能
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)
   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring); 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

;; 命令历史插件
(use-package amx
  :ensure t
  :init (amx-mode))

;; 更好的滚动效果(视觉效果)
(use-package good-scroll
  :ensure t
  :if window-system    ;在图像化界面时才使用这个插件.
  :init (good-scroll-mode))

;; 新的欢迎界面
 (use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs!") ;; 个性签名，随读者喜好设置
  ;; (setq dashboard-projects-backend 'projectile) ;; 读者可以暂时注释掉这一行，等安装了 projectile 后再使用
  (setq dashboard-startup-banner 'official) ;; 也可以自定义图片
  (setq dashboard-items '((recents  . 5)   ;; 显示多少个最近文件
			  (bookmarks . 5)  ;; 显示多少个最近书签
			  (projects . 10))) ;; 显示多少个最近项目
  (dashboard-setup-startup-hook))

;; 语法检查(仅在编程模式有效)
(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil) ; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))

;; 代码分析模块(未测试)
(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l"
	lsp-file-watch-threshold 500)
  :hook
  (lsp-mode . lsp-enable-which-key-integration) ; which-key integration
  :commands (lsp lsp-deferred)
  :config
  ;; 阻止 lsp 重新设置 company-backend 而覆盖我们 yasnippet 的设置
  (setq lsp-completion-provider :none)
  (setq lsp-headerline-breadcrumb-enable t)
  :bind
  ;; 可快速搜索工作区内的符号（类名、函数名、变量名等）
  ("C-c l s" . lsp-ivy-workspace-symbol))

(use-package lsp-ui
  :ensure t
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (setq lsp-ui-doc-position 'top))

(use-package lsp-ivy
  :ensure t
  :after (lsp-mode))

;; 代码补全模块
(use-package dap-mode
  :ensure t
  :after hydra lsp-mode
  :commands dap-debug
  :custom
  (dap-auto-configure-mode t)
  :config
  (dap-ui-mode 1)
  :hydra
  (hydra-dap-mode
   (:color pink :hint nil :foreign-keys run)
   "
^Stepping^          ^Switch^                 ^Breakpoints^         ^Debug^                     ^Eval
^^^^^^^^----------------------------------------------------------------------------------------------------------------
_n_: Next           _ss_: Session            _bb_: Toggle          _dd_: Debug                 _ee_: Eval
_i_: Step in        _st_: Thread             _bd_: Delete          _dr_: Debug recent          _er_: Eval region
_o_: Step out       _sf_: Stack frame        _ba_: Add             _dl_: Debug last            _es_: Eval thing at point
_c_: Continue       _su_: Up stack frame     _bc_: Set condition   _de_: Edit debug template   _ea_: Add expression.
_r_: Restart frame  _sd_: Down stack frame   _bh_: Set hit count   _ds_: Debug restart
_Q_: Disconnect     _sl_: List locals        _bl_: Set log message
                  _sb_: List breakpoints
                  _sS_: List sessions
"
   ("n" dap-next)
   ("i" dap-step-in)
   ("o" dap-step-out)
   ("c" dap-continue)
   ("r" dap-restart-frame)
   ("ss" dap-switch-session)
   ("st" dap-switch-thread)
   ("sf" dap-switch-stack-frame)
   ("su" dap-up-stack-frame)
   ("sd" dap-down-stack-frame)
   ("sl" dap-ui-locals)
   ("sb" dap-ui-breakpoints)
   ("sS" dap-ui-sessions)
   ("bb" dap-breakpoint-toggle)
   ("ba" dap-breakpoint-add)
   ("bd" dap-breakpoint-delete)
   ("bc" dap-breakpoint-condition)
   ("bh" dap-breakpoint-hit-condition)
   ("bl" dap-breakpoint-log-message)
   ("dd" dap-debug)
   ("dr" dap-debug-recent)
   ("ds" dap-debug-restart)
   ("dl" dap-debug-last)
   ("de" dap-debug-edit-template)
   ("ee" dap-eval)
   ("ea" dap-ui-expressions-add)
   ("er" dap-eval-region)
   ("es" dap-eval-thing-at-point)
   ("q" nil "quit" :color blue)
   ("Q" dap-disconnect :color red)))

;; 项目管理模块
(use-package projectile
  :ensure t
  :bind (("C-c p" . projectile-command-map))
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-track-known-projects-automatically nil)
  (setq projectile-project-search-path '("D:/WorkSpace/Project/"))
  (setq projectile-indexing-method 'hybrid)
  )


(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :init (counsel-projectile-mode))

;; 自动补全
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 2))

;; 显示自动补全的图标
(use-package company-box
  :ensure t
  :if window-system
  :hook (company-mode . company-box-mode))

;; 版本控制模块
(use-package magit
  :ensure t)
;; 各种语言模块:

;; C/C++
(use-package c++-mode
  :functions 			; suppress warnings
  c-toggle-hungry-state
  :hook
  (c-mode . lsp-deferred)
  (c++-mode . lsp-deferred)
  (c++-mode . c-toggle-hungry-state))

;; 调试模块:
(use-package dap-lldb
  :after dap-mode
  :custom
  (dap-lldb-debug-program '("C:/Users/xushunbin/scoop/apps/llvm/20.1.7/bin/lldb-dap"))
  ;; ask user for executable to debug if not specified explicitly (c++)
  (dap-lldb-debugged-program-function
   (lambda () (read-file-name "Select file to debug: "))))
;; C/C++ mode ends here.

;; python
(use-package python
  :defer t
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python3" . python-mode)
  :config
  ;; for debug
  (require 'dap-python))

(use-package pyvenv
  :ensure t
  :config
  (setenv "WORKON_HOME" (expand-file-name "C:/Users/xushunbin/scoop/apps/miniconda3/25.5.1-0/envs"))
  ;; (setq python-shell-interpreter "python3")  ; （可选）更改解释器名字
  (pyvenv-mode t)
  ;; （可选）如果希望启动后激活 miniconda 的 base 环境，就使用如下的 hook
  ;; :hook
  ;; (python-mode . (lambda () (pyvenv-workon "..")))
  )

;; 调试模块(LSP)
(use-package lsp-pyright
  :ensure t
  :config
  :hook
  (python-mode . (lambda ()
		  (require 'lsp-pyright)
		  (lsp-deferred))))
;; python mode ends here.
;; 语言模块结束

;; 工作区管理:
(use-package treemacs
  :ensure t
  :defer t
  :config
  (treemacs-tag-follow-mode)
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ;; ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  (:map treemacs-mode-map
	("/" . treemacs-advanced-helpful-hydra)))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package lsp-treemacs
  :ensure t
  :after (treemacs lsp))

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

;; 绑定项目扫描快捷键
(evil-define-key 'normal global-map (kbd "<leader>pR") 'projectile-discover-projects-in-search-path)

;; 剪贴板支持
(setq select-enable-clipboard t)
(setq save-interprogram-paste-before-kill t)

;; 快速编辑配置文件
(defun open-init-file ()
  "打开 Emacs 配置文件."
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

;;; init.el ends here
