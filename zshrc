# .zshrc is for interactive shell configuration. You set options for the
# interactive shell there with the setopt and unsetopt commands. You can
# also load shell modules, set your history options, change your prompt,
# set up zle and completion, et cetera. You also set any variables that
# are only used in the interactive shell (e.g. $LS_COLORS).

alias d1='d1=$(pwd);echo d1=$d1'
alias cd1='cd $d1'
alias d2='d2=$(pwd);echo d2=$d2'
alias cd2='cd $d2'
alias d3='d3=$(pwd);echo d3=$d3'
alias cd3='cd $d3'
alias qd='echo d1=$d1;echo d2=$d2;echo d3=$d3'

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

# Install zsh completions
autoload -U compinit && compinit

git_branch() {
    GB=$(git branch --show-current 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo -e " ($GB)\c "
    fi
}

setopt PROMPT_SUBST
export PROMPT='[%n@%m] %0~$(git_branch)>'
#To drop all but the final path segment:
#export PROMPT='[%n@%m] %1~$(git_branch)>'

# Allow comments in interactive shell
setopt interactivecomments

# Disable ! for history
setopt nobanghist

# Add dotnet tools (installed with dotnet tool command) to path
export PATH="$PATH:$HOME/.dotnet/tools"
