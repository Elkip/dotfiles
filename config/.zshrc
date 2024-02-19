neofetch --ascii

# Powerlevel 10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#PROMPT='%F{33}elkip%f%F{45}@%f%F{43}poppi%f%F{38}:%1~/%f %F{44}%#%f '

export EDITOR='vim'

## Aliases

alias vi="$EDITOR"
alias ls="la"
alias ll="eza -l --icons always"
alias la="eza -la --icons always"
alias lt="eza -a --tree --level=1 --icons always"
alias grep='grep --color=auto'
alias gst="git status"
alias push="git push origin main"
alias pull="git pull origin main"
alias shutdown="systemctl poweroff"
alias pydev="source /home/elkip/Packages/py3-base-dev/bin/activate"
alias work="source /home/elkip/Packages/py3-base-dev/bin/activate && cd /home/elkip/Workspace"
# Quick access
alias confh="$EDITOR /home/elkip/.config/hypr/hyprland.conf"
alias confw="$EDITOR /home/elkip/.config/waybar/config"
alias confz="$EDITOR /home/elkip/.zshrc"

## Settings

# Emacs keybindings
bindkey -e

# Case insensitive completion
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Search history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

## External Packages

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load Angular CLI autocompletion.
source <(ng completion script)

# zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The following lines were added by compinstall
zstyle :compinstall filename '/home/elkip/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# bun completions
[ -s "/home/elkip/.bun/_bun" ] && source "/home/elkip/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
