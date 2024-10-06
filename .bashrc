# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.
[[ $- != *i* ]] && return

shopt -s checkwinsize # http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s histappend # Enable history appending instead of overwriting.

# git prompt
command -v git &> /dev/null ; git_state=${?}
if [[ ${git_state} -eq 0 ]]
then
  source ${HOME}/.config/git/git-prompt.sh
  function __git_ps1__()
  {
    local git_prompt=$(__git_ps1 "${@}")
    [[ -n ${git_prompt} ]] && printf '%s ' ${git_prompt}
  }
fi

set_ps1()
{
  local esc='\[\e['
  local cse='m\]'

  printf -v root_addr_seq '%s' ${esc} '01;31' ${cse}
  printf -v addr_seq '%s' ${esc} ${1} ${cse}
  printf -v dir_seq '%s' ${esc} ${2} ${cse}
  printf -v git_seq '%s' ${esc} ${3} ${cse}
  printf -v prompt_seq '%s' ${esc} ${4} ${cse}
  printf -v end_seq '%s0%s' ${esc} ${cse}

  if [[ ${git_state} -eq 0 ]]
  then
    printf -v ps1_git '$(__git_ps1__ "%s%s")' ${git_seq} '%s'
  fi

  printf -v ps1_prompt '%s\$%s' ${prompt_seq} ${end_seq} # end all colors here
  if [[ ${EUID} == 0 ]]
  then
    printf -v ps1_host '%s\h%s' ${root_addr_seq}
    printf -v ps1_dir '%s\W%s' ${dir_seq}
  else
    printf -v ps1_user_at '%s\\u@%s' ${addr_seq}
    printf -v ps1_host '%s\h%s' ${addr_seq}
    printf -v ps1_dir '%s\w%s' ${dir_seq}
  fi

  if [[ -n ${ps1_git} ]]
  then
    printf '%s' "${ps1_user_at}${ps1_host} ${ps1_dir} ${ps1_git}${ps1_prompt} "
  else
    printf '%s' "${ps1_user_at}${ps1_host} ${ps1_dir} ${ps1_prompt} "
  fi
}

# exports ----------------------------------------------------------------------
[[ $(which ccache &> /dev/null) == 0 ]] && ( [[ $PATH =~ "/usr/lib/ccache/bin" ]] || export PATH=/usr/lib/ccache/bin:$PATH )
[[ $PATH =~ "${HOME}/.local/bin" ]] || export PATH=$HOME/.local/bin:$PATH
[[ $PYHTHONPATH =~ "${HOME}/.local/lib/python" ]] || export PYTHONPATH=$HOME/.local/lib64/python:$HOME/.local/lib/python:$PYTHONPATH
export EDITOR="vim"
export HISTFILESIZE=65536
export HISTSIZE=4096
export CFLAGS="-march=native -mtune=native -Os -fmessage-length=0 -pipe"
export CXXFLAGS="$CFLAGS" # -fno-implicit-templates"
export GPG_TTY=$(tty)  # Workaround for GPG 2.1 pinentry bug
export GIT_SSH=$HOME/.local/bin/git-ssh
export SCREENRC=$HOME/.local/share/pscreen/profiles/default
export CCACHE_DIR=$HOME/.cache/ccache
export F90CACHE_DIR=$HOME/.cache/f90cache
export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig
export IPYTHONDIR=$HOME/.config/ipython
export TIGRC_USER=$HOME/.config/tig
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LOCALE='en_US.UTF-8'
export LC_ALL=''
# ------------------------------------------------------------------------------

# aliases and alias functions --------------------------------------------------
which() { command alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde ${@}; }
tmux() { command tmux -f ${HOME}/.config/tmux/config ${@}; }
irssi() { command irssi --home=${HOME}/.config/irssi ${@}; }
dosbox() { command dosbox -conf ${HOME}/.config/dosbox/dosbox.conf ${@}; }
tig() { command tig -n 128 ${@}; }
ipy() { command ipython ${@}; }
ipy3() { command ipython3 ${@}; }
alias ls='ls --color=auto'
alias less='less -R -X'
alias tree='tree -C'
alias grep='grep --colour=auto'
# ------------------------------------------------------------------------------

# copy this into ~/.bash_local and adjust as desired ###########################
addr_color='01;36'
dir_color='01;34'
git_color='36;22'
prompt_color='01;34'
export PS1=$(set_ps1 ${addr_color} ${dir_color} ${git_color} ${prompt_color})
################################################################################

[[ -f ~/.bash_local ]] && source ~/.bash_local

unset git_state addr_color dir_color git_color prompt_color
