####### KOLORY
c_white="\[\e[37m\]"
c_celadon="\[\e[36m\]"
c_yellow="\[\e[33m\]"
c_green="\[\e[32m\]"
c_violet="\[\e[34m\]"
c_red="\[\e[31m\]"
c_reset="\[\e[0m\]"
c_bold_white='\[\033[1;29m\]'


gitdir()
{
    local dir="$(pwd)"
    while [ "$(dirname $dir)" != "/" ]; do
        [ -d "$dir/.git" ] && echo "$dir/.git" && return
        dir="$(dirname $dir)"
    done
    false
}

function is_git_dirty {
  (git status | tail -n1 | grep -v "nothing to commit") 2> /dev/null >/dev/null
}
function is_git_repo()
{
    local dir="$(pwd)"
    while [ "$(dirname "$dir")" != "/" ]; do
        [ -d "$dir/.git" ] && return
        dir="$(dirname "$dir")"
    done
    false
}
function current_branch {
  cat `gitdir`/HEAD | sed 's|ref: refs/heads/||'
}
function git_dirty_indicator {
  is_git_dirty && echo '*'
}
function git_indicator {
  if [ -n "$DISABLE_GIT_INDICATOR" ]; then
    return
  fi

  if ! is_git_repo;
  then
    echo ''
    return
  fi

  echo "${c_yellow}[$(current_branch)${c_red}$(git_dirty_indicator)${c_yellow}]$c_reset "
}
function parse_rvm_prompt {
  rvm-prompt | sed 's/\(ruby-\)\(.*\)@\(.*\)/\3/'
}
function rails_env_indicator {
  [ "$RAILS_ENV" = "production" ] && echo "${c_red}P$c_reset "
}

function hostname_indicator {
  case `hostname` in
    jumski-laptop)
      echo "${c_celadon}laptop$c_reset " ;;
    jumski-old)
      echo "${c_violet}old$c_reset " ;;
    jumski-akra)
      echo "${c_green}akra$c_reset " ;;
    s11.linuxpl.com)
      echo "${c_yellow}linuxpl$c_reset " ;;
  esac
}

function shortened_pwd {
  dirname "`pwd`" | sed 's:\B\w*::g'

}
function parent_dirname {
  dirname "`pwd`" | sed 's|/\(.*\)\+/\(.*\)|\2|g'
}

function pwd_indicator {
  echo "`parent_dirname `/${c_bold_white}`basename "$PWD"`$c_reset "
  # echo "`parent_dirname | head -c1 `/${c_white}`basename "$PWD"`$c_reset "
}

source $DOTFILES_PATH/bash/battery_functions.sh

function prompt_indicator {
  if [ $LAST_EXIT_CODE = 0 ];
  then
    indicator_color=$c_green
  else
    indicator_color=$c_red
  fi

  echo "${indicator_color}\$${c_reset} "
}

function todo_oneliner {
  # c_tip="\[\033[40m\]"
  # oneliner=$(egrep -v "(^\"|^\s*$)" ~/dotfiles/todo.txt | shuf -n 1)
  # echo "\n${c_tip}TODO: ${oneliner}${c_reset}\n"
  echo ""
}

horizontal_separator() {
  terminal_width=${COLUMNS:-$(tput cols)}
  datetime=$(date +'%Y-%m-%d %H:%M')
  padding_length=$(($terminal_width - ${#datetime} - 2))
  padding=$(printf '%*s\n' "$padding_length" '' | tr ' ' -)

  echo $padding $datetime
}

prompt_command() {
  LAST_EXIT_CODE=$?

  history -a
  PS1=$c_reset
  PS1="${PS1}$(horizontal_separator)"
  PS1="${PS1}\n"
  PS1="${PS1}$(hostname_indicator)"
  PS1="${PS1}$(pwd_indicator)"
  PS1="${PS1}$(git_indicator)"
  PS1="${PS1}$(rails_env_indicator)"
  PS1="${PS1}$(prompt_indicator)"
  PS1="${PS1}${c_white}"
  export PS1
}

PROMPT_COMMAND=prompt_command
