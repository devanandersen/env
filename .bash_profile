echo "HALLO."
alias ls="ls -G"
alias watch.rb="ruby ~/watch.rb ."
if [[ -f /opt/dev/dev.sh ]]; then source /opt/dev/dev.sh; fi
if [ -e /Users/devanandersen/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/devanandersen/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

mkin () {
        mkdir -p -- "$1" && cd -P -- "$1"
}

gitu () {
	git remote show origin
}

# added by Anaconda3 2019.07 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/Users/devanandersen/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/Users/devanandersen/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/devanandersen/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/Users/devanandersen/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
export MPLBACKEND="module://itermplot"
export ITERMPLOT=rv
# Added by install_latest_perl_osx.pl
[ -r /Users/devanandersen/.bashrc ] && source /Users/devanandersen/.bashrc

# Shell History
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'n'}history -a; history -c; history -r"
