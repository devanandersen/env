if ! type "zsh" > /dev/null
then
  echo "zsh could not be found, please install zsh first"
elif ! type "nvim" > /dev/null
then
  echo "neovim could not be found. please install neovim first"
else
  git clone https://github.com/devanandersen/env.git ~/
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions/
  cp ~/env/.bashrc ~/.bashrc
  cp ~/env/.zshrc ~/.zshrc
  cp ~/env/.vimrc ~/.vimrc
  rm -rf ~/env
  source ~/.zshrc
  vim +PluginInstall +qall
fi
