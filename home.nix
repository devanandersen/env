{ config, pkgs, lib, ... }:

{
  home.username = "devanandersen";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/devanandersen" else "/home/devanandersen";
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
    jq
    bat
    eza
    zoxide
    age
  ];

  home.file.".local/bin/cursor-worktree" = lib.mkIf (builtins.pathExists ./cursor-worktree.sh) {
    text = builtins.readFile ./cursor-worktree.sh;
    executable = true;
  };

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
          local color_file="/Users/devanandersen/world/trees/$worktree_name/.worktree-color"
          if [[ -f "$color_file" ]]; then
            local color=$(cat "$color_file")
            echo "%F{$color}[$worktree_name]%f "
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

      [[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
      
      [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
      
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
      vim-rails
      coc-solargraph
    ];

    extraConfig = ''
      set nocompatible
      filetype plugin indent on
      
      let mapleader = " "
      
      set rtp^=/nix/store/*/vim-pack-dir
      set packpath^=/nix/store/*/vim-pack-dir
      command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

      syntax on
      autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
      autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript
      set t_Co=256
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

      inoremap <silent><expr> <TAB>
            \ pumvisible() ? coc#_select_confirm() :
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',""])\<CR>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()

      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      let g:coc_snippet_next = '<tab>'

      if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
      else
        inoremap <silent><expr> <c-@> coc#refresh()
      endif

      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      let g:coc_global_extensions = ['coc-solargraph']
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
}
