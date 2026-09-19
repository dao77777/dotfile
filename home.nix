# ~/.config/home-manager/home.nix
{ config, pkgs, ... }:

{
  # 指定 Home Manager 管理的主目录和用户名
  home.username = "zephyr";          # 改成你的用户名
  home.homeDirectory = "/Users/zephyr";  # macOS 用 /Users/xxx，Linux 用 /home/xxx

  # 环境变量
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # 声明要安装的所有包(分类与 README.md 一致)
  home.packages = with pkgs; [
    # ── 文件系统:浏览与管理 ──
    eza
    dua
    duf

    # ── 文件系统:搜索与查找 ──
    fd
    ripgrep
    fzf

    # ── 文件系统:处理与转换 ──
    curl
    wget
    jq
    yq
    p7zip

    # ── 文件系统:渲染与预览 ──
    bat
    poppler-utils # PDF(pdftoppm/pdftotext)
    resvg         # SVG
    ffmpeg        # 音视频
    imagemagick   # 图片(magick/convert)

    # ── 开发 ──
    git
    gh
    lazygit
    nodejs
    go
    rustup
    process-compose

    # ── Shell 与系统 ──
    pfetch
  ];

  # ══════════════════════════════════════
  # ── 文件系统:浏览与管理 ──
  # ══════════════════════════════════════

  # yazi 文件管理器: y 命令退出后 cd 到浏览时所在目录
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  # 智能目录跳转
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ══════════════════════════════════════
  # ── Shell 与系统 ──
  # ══════════════════════════════════════

  # 管理 dotfiles
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";  # vi 模式: Esc 进入 normal 模式
    oh-my-zsh = {
      enable = true;
      theme = "";  # 由 starship 接管提示符
    };
    shellAliases = {
      # ls 系列(基于 eza) 2x2 矩阵: 横向/竖向 × 隐藏
      ls = "eza --icons --group-directories-first";
      l = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git";
      la = "eza -a --icons --group-directories-first";
      lla = "eza -la --icons --group-directories-first --git";
      lt = "eza -l --icons --tree --level=2";

      # cat 系列(基于 bat)
      bathelp = "bat --plain --language=help";

      # 查找与搜索
      rgi = "rg -i";

      # 系统监控
      bt = "btop";

      # 文件管理
      # y 由 programs.yazi.shellWrapperName 提供(退出时 cd 到浏览目录)

      # 模糊查找
      fzfp = "fzf --preview 'bat --color=always --style=numbers --line-range=:300 {}'";

      # git 简写
      g = "git";
      gs = "git status";
      gl = "git log --oneline --graph --decorate -20";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";

      # 目录跳转
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # 常用
      c = "clear";
      h = "history";
      ports = "lsof -i -P -n | grep LISTEN";
      reload = "source ~/.zshrc";

      # 编辑器
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
    };
    initContent = ''
      # oh-my-zsh 会执行 bindkey -e 覆盖 vi 模式,这里在其后重新启用
      bindkey -v

      # 每次打开交互式 shell 时打印系统信息(避免在嵌套 shell 中重复打印)
      if [[ -o interactive && -z "$PFETCH_SHOWN" ]]; then
        pfetch
        export PFETCH_SHOWN=1
      fi
    '';
  };

  # 现代化跨 shell 提示符
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # btop 配置 (Catppuccin Frappe 主题)
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_frappe";
    };
    themes.catppuccin_frappe = ''
      # Main background, empty for terminal default, need to be empty if you want transparent background
      theme[main_bg]="#303446"
      # Main text color
      theme[main_fg]="#c6d0f5"
      # Title color for boxes
      theme[title]="#c6d0f5"
      # Highlight color for keyboard shortcuts
      theme[hi_fg]="#8caaee"
      # Background color of selected item in processes box
      theme[selected_bg]="#51576d"
      # Foreground color of selected item in processes box
      theme[selected_fg]="#8caaee"
      # Color of inactive/disabled text
      theme[inactive_fg]="#838ba7"
      # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
      theme[graph_text]="#f2d5cf"
      # Background color of the percentage meters
      theme[meter_bg]="#51576d"
      # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
      theme[proc_misc]="#f2d5cf"
      # CPU, Memory, Network, Proc box outline colors
      theme[cpu_box]="#ca9ee6" #Mauve
      theme[mem_box]="#a6d189" #Green
      theme[net_box]="#ea999c" #Maroon
      theme[proc_box]="#8caaee" #Blue
      # Box divider line and small boxes line color
      theme[div_line]="#737994"
      # Temperature graph color (Green -> Yellow -> Red)
      theme[temp_start]="#a6d189"
      theme[temp_mid]="#e5c890"
      theme[temp_end]="#e78284"
      # CPU graph colors (Teal -> Lavender)
      theme[cpu_start]="#81c8be"
      theme[cpu_mid]="#85c1dc"
      theme[cpu_end]="#babbf1"
      # Mem/Disk free meter (Mauve -> Lavender -> Blue)
      theme[free_start]="#ca9ee6"
      theme[free_mid]="#babbf1"
      theme[free_end]="#8caaee"
      # Mem/Disk cached meter (Sapphire -> Lavender)
      theme[cached_start]="#85c1dc"
      theme[cached_mid]="#8caaee"
      theme[cached_end]="#babbf1"
      # Mem/Disk available meter (Peach -> Red)
      theme[available_start]="#ef9f76"
      theme[available_mid]="#ea999c"
      theme[available_end]="#e78284"
      # Mem/Disk used meter (Green -> Sky)
      theme[used_start]="#a6d189"
      theme[used_mid]="#81c8be"
      theme[used_end]="#99d1db"
      # Download graph colors (Peach -> Red)
      theme[download_start]="#ef9f76"
      theme[download_mid]="#ea999c"
      theme[download_end]="#e78284"
      # Upload graph colors (Green -> Sky)
      theme[upload_start]="#a6d189"
      theme[upload_mid]="#81c8be"
      theme[upload_end]="#99d1db"
      # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
      theme[process_start]="#85c1dc"
      theme[process_mid]="#babbf1"
      theme[process_end]="#ca9ee6"
    '';
  };

  # ══════════════════════════════════════
  # ── 开发 ──
  # ══════════════════════════════════════

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "dao77777";
        email = "dao77777@qq.com";
      };
      safe = {
        directory = "*";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Neovim 配置 (Catppuccin Frappe 主题)
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
    ];
    initLua = ''
      require("catppuccin").setup({
        flavour = "frappe",
      })
      vim.cmd.colorscheme "catppuccin"
    '';
  };

  # 配置 npm 全局安装路径
  programs.npm = {
    enable = true;
  };
  
  # 手动配置 npm 前缀
  home.file.".npmrc".text = ''
    prefix = ${config.home.homeDirectory}/.npm-global
  '';
  
  # 把 npm 全局 bin 目录加到 PATH
  home.sessionPath = [ "$HOME/.npm-global/bin" "$HOME/.local/bin" ];

  # ══════════════════════════════════════
  # ── Nix 生态 ──
  # ══════════════════════════════════════

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;

  # 重要：每次修改 home.nix 后，这个版本号要手动加 1
  # 或者直接用 "24.11" 这样的字符串
  home.stateVersion = "24.11";
}
