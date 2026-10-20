hyfetch

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
zstyle :compinstall filename '/home/elkip/.zshrc'
autoload -Uz colors && colors
autoload -Uz vcs_info
autoload -Uz compinit
compinit


setopt PROMPT_SUBST
PROMPT='
%F{39}╭─%f %F{51}󰣇 %n%f %F{240}@%f %F{213}%m%f %F{45}%~%f ${vcs_info_msg_0_:+%F{220}${vcs_info_msg_0_}%f %(?.%F{46}✔.%F{196}✘)%f
%F{39}╰─❯%f '

RPROMPT='%F{244}%D{%H:%M:%S}%f'
# End of lines added by compinstall

export EDITOR=vim
export CHROME_BIN=/usr/bin/chromium
# Aliases
alias vi='vim'
alias ls='eza --icons -lah'
alias confh='$EDITOR ~/.config/hypr/hyprland.lua'
alias confw='$EDITOR ~/.config/waybar/config.jsonc'
alias confz='$EDITOR ~/.zshrc'
alias pydev='source Packages/Python/pydev/bin/activate'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/nvm/init-nvm.sh

# Load Angular CLI autocompletion.
source <(ng completion script)
