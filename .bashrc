# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.
[[ $- != *i* ]] && return

shopt -s checkwinsize # http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s histappend # Enable history appending instead of overwriting.

set_term()
{
  case ${TERM} in
    xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix)
      PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
      ;;
    screen*)
      PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
      ;;
  esac
}

test_color()
{
  local safe_term=${TERM//[^[:alnum:]]/?}
  local dir_colors=''
  if [[ -f ~/.config/DIR_COLORS ]]
  then
    dir_colors="$(<~/.config/DIR_COLORS)"
  elif [[ -f /etc/DIR_COLORS ]]
  then
    dir_colors="$(</etc/DIR_COLORS)"
  fi
  if [[ -z ${dir_colors} ]]
  then
    type -P dircolors &> /dev/null
    dir_colors=$(dircolors --print-database)
  fi
  [[ $'\n'${dir_colors} == *$'\n'"TERM "${safe_term}* ]] && use_color=true
}

set_color()
{
  if ${use_color}
  then
    if ( type -P dircolors &> /dev/null )
    then
      if [[ -f ~/.config/DIR_COLORS ]]
      then
        eval $(dircolors -b ~/.config/DIR_COLORS &> /dev/null)
      elif [[ -f /etc/DIR_COLORS ]]
      then
        eval $(dircolors -b /etc/DIR_COLORS)
      fi
    fi
  fi
}

use_color=false
set_term ; test_color ; set_color

# git-prompt.sh cannot be used without color
if ${use_color}
then
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
fi

set_ps1()
{
  if ${use_color}
  then
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

# aliases ----------------------------------------------------------------------
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias tmux="tmux -f ${HOME}/.config/tmux/config"
alias irssi="irssi --home=${HOME}/.config/irssi"
alias dosbox="dosbox -conf ${HOME}/.config/dosbox/dosbox.conf"
alias tig="tig -n 128"
if ${use_color}
then
  alias ls='ls --color=auto'
  alias less='less -R -X'
  alias tree='tree -C'
  alias grep='grep --colour=auto'
  alias egrep='egrep --colour=auto'
  alias fgrep='fgrep --colour=auto'
fi
# ------------------------------------------------------------------------------

# exports ----------------------------------------------------------------------
[[ $PATH =~ "/usr/lib/ccache/bin" ]] || export PATH=/usr/lib/ccache/bin:$PATH
[[ $PATH =~ "${HOME}/.local/bin" ]] || export PATH=$HOME/.local/bin:$PATH
[[ $PYHTHONPATH =~ "${HOME}/.local/lib/python" ]] || export PYTHONPATH=$HOME/.local/lib64/python:$HOME/.local/lib/python:$PYTHONPATH
export EDITOR="vim"
export HISTFILESIZE=65536
export HISTSIZE=4096
export CFLAGS="-march=native -mtune=native -Os -fmessage-length=0 -pipe"
export CXXFLAGS="$CFLAGS" # -fno-implicit-templates"
export GIT_SSH=$HOME/.local/bin/git-ssh
export SCREENRC=$HOME/.local/share/pscreen/profiles/base
export CCACHE_DIR=$HOME/.cache/ccache
export F90CACHE_DIR=$HOME/.cache/f90cache
export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig
export IPYTHONDIR=$HOME/.config/ipython
export TIGRC_USER=$HOME/.config/tig
export TZ='America/Denver'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LOCALE='en_US.UTF-8'
export LC_ALL=''
# ------------------------------------------------------------------------------

# copy this into ~/.bash_local and adjust as desired ###########################
addr_color='01;36'
dir_color='01;34'
git_color='36;22'
prompt_color='01;34'
export PS1=$(set_ps1 ${addr_color} ${dir_color} ${git_color} ${prompt_color})
################################################################################

[[ -f ~/.bash_local ]] && source ~/.bash_local

unset use_color git_state addr_color dir_color git_color prompt_color
