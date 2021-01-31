# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
PATH=$PATH:/usr/local/sbin
export prompt='%F{magenta}D %1~%f ◉ '

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

mkin () {
        mkdir -p -- "$1" && cd -P -- "$1"
}

gitu () {
	git remote show origin
}

TOKEN=<redacted>

alias vim="nvim -u ~/.vimrc"
alias ls="ls -G"
alias weather="curl -4 wttr.in"
alias d='dirs -v | head -10'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias pls="sudo"
alias py3serve="python3 -m http.server"
alias mdpreview="grip"
alias tar="COPYFILE_DISABLE=1 tar"
alias clear_dns="sudo killall -HUP mDNSResponder; echo dns cleared successfully"
alias get_dns="scutil --dns"
alias mtr="sudo mtr"

alias dsgone="defaults write com.apple.desktopservices DSDontWriteNetworkStores false" # mac only
alias cpucheck="pmset -g thermlog" # mac only
alias its-ok-cpu="sudo mdutil -a -i off" # mac only
alias cpu-go-boom="sudo mdutil -a -i on" # mac only
