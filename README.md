# Dev Environment - Nix Edition

Reproducible development environment using Nix flakes with modern tools and smart defaults.

## Prerequisites

Install Nix, Git, Brew on your system:

Nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Git - https://git-scm.com/install/

Brew `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

## Setup

1. Clone this repository:
```bash
git clone https://github.com/devanandersen/env.git ~/env
cd ~/env
```

2. Enable flakes:

Add 

```
experimental-features = nix-command flakes
```

to whatever is existing, see

```
cat ~/.config/nix/nix.conf
cat /etc/nix/nix.conf
cat /nix/var/nix/profiles/default/etc/nix/nix.conf
```

3. Apply the configuration:

`sudo systemctl restart nix-daemon`

For mac

`sudo launchctl kickstart -k system/org.nixos.nix-daemon`

**For Mac (Apple Silicon):**
```bash
nix run home-manager/master -- switch --flake .#devan
```

**For Linux:**
```bash
  nix run home-manager/master -- switch --flake .#devanandersen@x86_64-linux
```

After the initial installation on Apple Silicon, you can use the `nix-update` alias from anywhere to apply configuration changes.

## What's Included

### Shell & Terminal
- **zsh** with autosuggestions and custom prompt
- **direnv** with nix-direnv for project-specific environments
- **zoxide** - smarter `cd` that learns your habits (use `z` command)

### Modern CLI Tools
- **eza** - better `ls` (aliased to `ls`)
- **bat** - better `cat` with syntax highlighting (aliased to `cat`)
- **ripgrep** - blazing fast grep
- **fzf** - fuzzy finder
- **jq** - JSON processor

### Editor
- **neovim** with plugins:
  - telescope.nvim - modern fuzzy finder
  - fzf.vim - additional fuzzy finding
  - coc.nvim - LSP support with Node.js and Ruby providers
  - nerdtree - file explorer
  - vim-fugitive - git integration
  - vim-go, vim-rails - language support

### Development
- **git** with global gitignore for macOS system files
- **nodejs** & **ruby** with neovim integration
- **ctags** for code navigation

## Key Bindings & Aliases

### Shell Aliases
- `ls` → `eza` (modern ls)
- `cat` → `bat` (syntax highlighted cat)
- `vim` → `nvim`
- `code` → `cursor`
- `z <dir>` → smart directory jumping

### Vim Key Bindings
- `↑` → `:Rg` (ripgrep search)
- `↓` → `:Files` (file finder)
- `<leader>ff` → Telescope find files
- `<leader>fg` → Telescope live grep
- `ff`, `ft`, `fb`, `fc`, `fl` → various FZF commands

## Supported Systems

- aarch64-darwin (Apple Silicon) - use `#devan`
- x86_64-linux - use `#devanandersen@x86_64-linux`

## Updating

To update all packages to latest versions:
```bash
nix flake update
nix run home-manager/master -- switch --flake .#devan  # For Mac
# or
nix run home-manager/master -- switch --flake .#devanandersen@x86_64-linux  # For Linux
```
