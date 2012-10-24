#!/bin/bash
step(){
  echo " > $@"
  "$@" 2>&1 >/dev/null
}

step cd ~/dotfiles/    &&
step git stash         &&
step git pull --rebase &&
step git stash pop     &&
step git stash pop     &&
step ./install.sh      &&
step source bashrc     &&
step mux steptfilez