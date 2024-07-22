. ~/.bashrc
# # don't put duplicate lines or lines starting with space in the history.
# # See bash(1) for more options
# HISTCONTROL=ignoreboth
# HISTIGNORE='poweroff'
#
# # append to the history file, don't overwrite it
# shopt -s histappend
#
# # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000
#
# # check the window size after each command and, if necessary,
# # update the values of LINES and COLUMNS.
# shopt -s checkwinsize
#
# force_color_prompt='yes'
# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#     # We have color support; assume it's compliant with Ecma-48
#     # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
#     # a case would tend to support setf rather than setaf.)
#     color_prompt=yes
#     else
#     color_prompt=
#     fi
# fi
#
# export LC_ALL='en_US.UTF-8'
#
# PS0='\e[2 q\2'
# if [ "$color_prompt" = yes ]; then
#     PS1='\[\033[38;5;012m\]┌─[\[\033[01;32m\]\u@\h\[\033[38;5;012m\]][\[\033[01;33m\]$CONDA_DEFAULT_ENV\[\033[38;5;012m][\[\033[38;5;4m\]$(git branch 2>/dev/null | sed -n "s/* \(.*\)/\1/p ")\[\033[38;5;012m\]][\[\033[38;5;63m\]\w\[\033[38;5;012m\]]\n\[\033[38;5;012m\]└─\[\033[38;5;27m\]$ \[\e[0m\]'
#     #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt
#
# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac
#
# # enable color support of ls and also add handy aliases
# if [ -x /usr/bin/dircolors ]; then
#     test -r ~/.dir_colors/dircolors && eval "$(dircolors -b ~/.dir_colors/dircolors)"
#     #test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
#     alias ls='ls --color=auto'
#     #alias dir='dir --color=auto'
#     #alias vdir='vdir --color=auto'
#
#     alias grep='grep --color=auto'
#     alias fgrep='fgrep --color=auto'
#     alias egrep='egrep --color=auto'
# fi
#
# # colored GCC warnings and errors
# #export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
#
# # some more ls aliases
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'
#
# # Alias definitions.
# # You may want to put all your additions into a separate file like
# # ~/.bash_aliases, instead of adding them here directly.
# # See /usr/share/doc/bash-doc/examples in the bash-doc package.
#
# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi
#
# if [ -f /usr/local/bin/aws_completer ]; then
#     complete -C '/usr/local/bin/aws_completer' aws
# fi
#
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup=$("${HOME}/miniconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "${HOME}/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="${HOME}/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
#
# eval "$(/opt/homebrew/bin/brew shellenv)"
#
# PATH="${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin:${PATH}"
#
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
# set -o vi
