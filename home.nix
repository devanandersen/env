{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Age secrets configuration
  age = {
    identityPaths = [ 
      "${config.home.homeDirectory}/.config/age/keys.txt"
    ];
    
    secrets = lib.mkIf (builtins.pathExists ./secrets/private-config.age) {
      private-config = {
        file = ./secrets/private-config.age;
        path = "${config.home.homeDirectory}/.config/secrets/private-config";
      };
    };
  };

  home.packages = with pkgs; [
    git
    ripgrep
    fzf
    ctags
    curl
    nodejs
    ruby
    rubyPackages.rails
    rubyPackages.solargraph
    jq
    bat
    eza
    zoxide
    age
    iterm2
  ];

  home.file.".local/bin/cursor-worktree" = lib.mkIf (builtins.pathExists ./cursor-worktree.sh) {
    text = builtins.readFile ./cursor-worktree.sh;
    executable = true;
  };

  # Hammerspoon configuration - direct symlink for live editing
  home.activation.linkHammerspoon = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -L "$HOME/.hammerspoon" ]]; then
      $DRY_RUN_CMD rm -rf "$HOME/.hammerspoon"
      $DRY_RUN_CMD ln -s "$HOME/Documents/env/hammerspoon" "$HOME/.hammerspoon"
    fi
  '';

  # Karabiner-Elements configuration
  home.file.".config/karabiner/karabiner.json" = {
    source = ./karabiner/karabiner.json;
    force = true;
  };

  # iTerm2 Dynamic Profile - only link if not already present
  home.activation.linkItermProfile = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ITERM_PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    ITERM_PROFILE_PATH="$ITERM_PROFILE_DIR/profile.json"

    if [[ ! -e "$ITERM_PROFILE_PATH" ]]; then
      $DRY_RUN_CMD mkdir -p "$ITERM_PROFILE_DIR"
      $DRY_RUN_CMD ln -s "$HOME/Documents/env/.iterm_profile.json" "$ITERM_PROFILE_PATH"
    fi
  '';

  # Claude Code commands - symlink for live editing
  home.activation.linkClaudeCommands = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CLAUDE_COMMANDS="$HOME/.claude/commands"
    if [[ ! -L "$CLAUDE_COMMANDS" ]]; then
      $DRY_RUN_CMD rm -rf "$CLAUDE_COMMANDS"
      $DRY_RUN_CMD mkdir -p "$HOME/.claude"
      $DRY_RUN_CMD ln -s "$HOME/Documents/env/.claude/commands" "$CLAUDE_COMMANDS"
    fi
  '';

  # CoC configuration
  home.file.".config/nvim/coc-settings.json".source = ./coc-settings.json;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    
    history = {
      size = 10000;
      save = 10000;
      share = true;
    };
    
    sessionVariables = {
    };

    shellAliases = {
      vim = "nvim";
      ls = "eza --git";
      ll = "eza -la --git";
      cat = "bat";
      weather = "curl -4 wttr.in";
      clear_dns = "sudo killall -HUP mDNSResponder; echo dns cleared successfully";
      get_dns = "scutil --dns";
      code = "cursor";
      gentags = "ctags -R --exclude=.git --exclude=log *";

      # Mac-only aliases (will only work on Darwin)
      dsgone = "defaults write com.apple.desktopservices DSDontWriteNetworkStores false";
      cpucheck = "pmset -g thermlog";
      its-ok-cpu = "sudo mdutil -a -i off";
      cpu-go-boom = "sudo mdutil -a -i on";
    };

    initContent = ''
      # Function to extract worktree name from path
      worktree_prompt() {
        local current_path="$PWD"
        if [[ "$current_path" =~ /trees/([^/]+) ]]; then
          local worktree_name="''${match[1]}"
          local color_file="${config.home.homeDirectory}/world/trees/$worktree_name/.worktree-color"
          if [[ -f "$color_file" ]]; then
            local hex=$(cat "$color_file" | tr -d '#\n' | tr -d '\r')
            # Validate and convert hex to RGB for terminal
            if [[ ''${#hex} -eq 6 ]]; then
              local r=$((16#''${hex:0:2}))
              local g=$((16#''${hex:2:2}))
              local b=$((16#''${hex:4:2}))
              echo "%{$(printf '\033[38;2;%d;%d;%dm' $r $g $b)%}[$worktree_name]%{$(printf '\033[0m')%} "
            else
              echo "%F{cyan}[$worktree_name]%f "
            fi
          else
            echo "%F{cyan}[$worktree_name]%f "
          fi
        fi
      }

      # Set up precmd to update prompt
      precmd() {
        export PROMPT="%F{magenta}D%f $(worktree_prompt)%F{magenta}%1~%f "
      }

      PATH=$PATH:/usr/local/sbin
      
      # Initialize zoxide for smarter cd
      eval "$(zoxide init zsh)"
      
      # Source private configuration from age secret if it exists
      if [[ -f "${config.home.homeDirectory}/.config/secrets/private-config" ]]; then
        source "${config.home.homeDirectory}/.config/secrets/private-config"
      fi
      
      mkin () {
        mkdir -p -- "$1" && cd -P -- "$1"
      }

      gitu () {
        git remote show origin
      }

      reset-worktree-colours () {
        echo "Resetting worktree colours..."
        # Remove all cursor workspace files
        rm -f ~/.cursor-workspaces/*.code-workspace 2>/dev/null
        # Remove all .worktree-color files
        find ~/world/trees -maxdepth 2 -name ".worktree-color" -delete 2>/dev/null
        echo "Done! Run cursor-worktree in each worktree to generate new colours."
      }

      nix-update () {
        cd ~/Documents/env && nix run home-manager/master -- switch --flake ".#$USER" && cd -
      }

      [[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
      
      [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

      # tec profile (after Homebrew so tec tools take precedence)
      if [[ -x "$HOME/.local/state/tec/profiles/base/current/global/init" ]]; then
        eval "$("$HOME/.local/state/tec/profiles/base/current/global/init" zsh)"
      fi

      # Ensure Nix takes precedence over everything else
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Add ~/.local/bin to PATH for home-manager managed scripts
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.neovim = {
    enable = true;
    vimAlias = false;
    vimdiffAlias = true;
    withRuby = true;
    withNodeJs = true;
    
    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      telescope-nvim
      plenary-nvim  # telescope dependency
      fzf-vim
      nerdtree
      vim-go
      coc-nvim
      coc-snippets
      vim-rails
      vim-ruby
      coc-solargraph
    ];

    extraConfig = ''
      set nocompatible
      filetype on
      filetype plugin on
      filetype indent on
      
      let mapleader = " "
      
      set rtp^=/nix/store/*/vim-pack-dir
      set packpath^=/nix/store/*/vim-pack-dir
      command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

      syntax enable
      colorscheme habamax
      autocmd BufNewFile,BufRead *.rb setlocal filetype=ruby
      autocmd BufNewFile,BufRead *.rake setlocal filetype=ruby
      autocmd BufNewFile,BufRead *.eru setlocal filetype=ruby
      autocmd BufNewFile,BufRead Gemfile setlocal filetype=ruby
      autocmd BufNewFile,BufRead Rakefile setlocal filetype=ruby
      autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
      autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript
      set t_Co=256
      set termguicolors
      set number
      set relativenumber
      set clipboard=unnamed
      set clipboard=unnamedplus
      set autoindent
      set incsearch
      set hlsearch
      set autoread
      set ruler
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set tw=120
      set fo+=t

      function! SetTerminalTitle()
          let titleString = expand('%:t')
          if len(titleString) > 0
              let &titlestring = expand('%:t')
              let args = "\033];".&titlestring."\007"
              let cmd = 'silent !echo -e "'.args.'"'
              execute cmd
              redraw!
          endif
      endfunction
      autocmd BufEnter * call SetTerminalTitle()

      map <up> :Rg
      map <down> :Files
      :tnoremap <Esc> <C-\><C-n>
      :set mouse=a

      nnoremap ff :Files <CR>
      nnoremap ft :Tags <CR>
      nnoremap fT :BTags <CR>
      nnoremap fb :Buffers <CR>
      nnoremap fc :Rg <CR>
      nnoremap fl :BLines <CR>
      
      " Telescope mappings
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>

      set encoding=utf-8
      set hidden
      set nobackup
      set nowritebackup
      set cmdheight=2
      set updatetime=300
      set shortmess+=c

      if has("nvim-0.5.0") || has("patch-8.1.1564")
        set signcolumn=number
      else
        set signcolumn=yes
      endif

      inoremap <silent><expr> <TAB> pumvisible() ? "\<C-y>" : "\<TAB>"
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
      else
        inoremap <silent><expr> <c-@> coc#refresh()
      endif

      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      let g:coc_global_extensions = ['coc-solargraph', 'coc-snippets']
      let g:coc_extension_auto_update = 0
      let g:solargraph_disable_auto_update = 1
      let g:snipMate = { 'snippet_version' : 1 }
      :command Rdef call CocAction('jumpDefinition')
      set tags=./tags;

      let g:CommandTPreferredImplementation='lua'
    '';
  };

  programs.git = {
    enable = true;
    userName = "devanandersen";
    userEmail = "devanandersenbusiness@gmail.com";
    extraConfig = {
      push.default = "current";
      init.defaultBranch = "main";
    };
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".AppleDouble"
      ".LSOverride"
      "Icon"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
      ".worktree-color"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Install Homebrew if not present (macOS only)
  home.activation.installHomebrew = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ ! -x /opt/homebrew/bin/brew ]]; then
        echo "Homebrew not found, installing..."
        $DRY_RUN_CMD /bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || echo "Homebrew installation failed"
      fi
    ''
  );

  # Homebrew cask installation (macOS only)
  home.activation.installHomebrewCasks = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter ["installHomebrew"] ''
      if [[ -x /opt/homebrew/bin/brew ]]; then
        echo "Checking Homebrew casks..."

        # Only install hammerspoon if not already installed
        if ! /opt/homebrew/bin/brew list --cask hammerspoon &>/dev/null; then
          echo "Installing hammerspoon..."
          $DRY_RUN_CMD /opt/homebrew/bin/brew install --cask --no-quarantine hammerspoon || true
        fi

        # Only install karabiner-elements if not already installed
        if ! /opt/homebrew/bin/brew list --cask karabiner-elements &>/dev/null; then
          echo "Installing karabiner-elements..."
          $DRY_RUN_CMD /opt/homebrew/bin/brew install --cask karabiner-elements || true
        fi
      else
        echo "Homebrew not found at /opt/homebrew/bin/brew, skipping cask installation"
      fi
    ''
  );
}
