#export PS1="D \W$ "
#alias ls="ls -G"
#alias watch.rb="ruby ~/watch.rb ."
#alias devserver="rails webpacker:install && dev server"
#alias rails_reset="rails db:drop && rails db:create && rails db:migrate"
#alias rails_reset_seed="rails db:drop && rails db:create && rails db:migrate && rails db:seed"
#alias weather="curl -4 wttr.in"
#alias vim="nvim"
#
#if [[ -f /opt/dev/dev.sh ]]; then source /opt/dev/dev.sh; fi
#if [ -e /Users/devanandersen/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/devanandersen/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
#
#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
#
#mkin () {
#        mkdir -p -- "$1" && cd -P -- "$1"
#}
#
#gitu () {
#	git remote show origin
#}
#
#TOKEN=a4309608cc40d2c334b697c6bfc6322bc7c87eb6
## added by Anaconda3 2019.07 installer
## >>> conda init >>>
## !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$(CONDA_REPORT_ERRORS=false '/Users/devanandersen/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    \eval "$__conda_setup"
#else
#    if [ -f "/Users/devanandersen/anaconda3/etc/profile.d/conda.sh" ]; then
#        . "/Users/devanandersen/anaconda3/etc/profile.d/conda.sh"
#        CONDA_CHANGEPS1=false conda activate base
#    else
#        \export PATH="/Users/devanandersen/anaconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
## <<< conda init <<<
#export MPLBACKEND="module://itermplot"
#export ITERMPLOT=rv
## Added by install_latest_perl_osx.pl
#[ -r /Users/devanandersen/.bashrc ] && source /Users/devanandersen/.bashrc
zsh
source ~/.zshrc
