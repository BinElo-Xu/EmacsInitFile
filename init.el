;;; init.el --- the configuration of emacs.
;;; commentary:

;; ====================
;; Vim 用户专属 Emacs 配置
;; 保存为 ~/.emacs.d/init.el
;; ====================

;;; Code:
;; -- 关闭所有声音提示 --
(setq ring-bell-function 'ignore) ; 关闭错误提示音
(setq visible-bell nil)           ; 关闭视觉提示（闪烁）
; 禁用默认界面元素
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;;禁用烦人的警告
(setq-default byte-compile-warnings
              '(docstrings
                free-vars
                unresolved
                obsolete
                call-graph      ; 编译器无法分析函数调用图，通常因为动态调用
                cl-functions    ; 使用了 cl-lib 但未显式 require 'cl-lib
                suspicious      ; 一些可疑但通常没问题的代码结构
                ))

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

;;确保Emacs继承shell的PATH环境变量
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (setq exec-path-from-shell-variables
          '("PATH"
            "MANPATH"
            "LC_ALL"
            "LC_CTYPE"
            "LANG"
            "CONDA_EXE"
            "CONDA_PREFIX"
            "CONDA_PYTHON_EXE"
            "CONDA_SHLVL"
            "CONDA_DEFAULT_ENV"))
    (exec-path-from-shell-initialize))
  )
;; 按键提示模块
(use-package which-key
  :ensure t
  :init
  (which-key-mode))

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
  (setq projectile-project-search-path '("~/WorkSpace"))
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-max-depth 8)
  )


(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :init (counsel-projectile-mode))
;;代码片段引擎
(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode) ;在所有编程模式中启动
  :config
  ;(yas-global-mode 1)
  )

;; 自动补全
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.2)
  (setq company-minimum-prefix-length 2)
  (with-eval-after-load 'company
    (add-to-list 'company-backend 'company-yasnippet))
  )

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
  (dap-lldb-debug-program '("lldb-dap"))
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
  (with-eval-after-load 'dap-python
    (setq dap-python-debugger 'debugpy))
  (require 'dap-python)
  )
;; python环境管理模块
(use-package pyvenv
  :ensure t
  :config
  (setenv "WORKON_HOME" (expand-file-name "~/miniconda3/envs"))
  ;; (setq python-shell-interpreter "python3")  ; （可选）更改解释器名字
  (pyvenv-mode t)
  ;; （可选）如果希望启动后激活 miniconda 的 base 环境，就使用如下的 hook
  ;; :hook
  ;; (python-mode . (lambda () (pyvenv-workon "..")))
  )

;; python调试模块(LSP)
(use-package lsp-pyright
  :ensure t
  :config
  :hook
  (python-mode . (lambda ()
		  (require 'lsp-pyright)
		  (lsp-deferred))))
;; python mode ends here.

;;java Language Support
;; ==================================
;; Java Language Support (最终正确版)
;; ==================================

;; ---------------------------------
;; 1. LSP for Code Intelligence
;; ---------------------------------
(use-package lsp-java
  :ensure t
  :config
  ;; 这是核心：将 lsp-mode 挂载到 java-mode 上
  (add-hook 'java-mode-hook 'lsp)
  (require 'dap-java)
  )

; java mode ends here.
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
 '(package-selected-packages
   '(0blayout use-package-hydra treemacs-projectile pyvenv magit lsp-ui lsp-pyright lsp-ivy key-chord good-scroll flycheck exec-path-from-shell evil-collection doom-themes doom-modeline dashboard dap-mode counsel-projectile company-box amx)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.

)
;;; init.el ends here
