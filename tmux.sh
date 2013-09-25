#!/bin/bash

# Reference:
# goo.gl/oZS5dH


# configs
backup_dir=~/.bak/tmux_snapshot
export PATH="${PATH}:/usr/local/bin"
task=${1}
target=${2}

if ! type tmux > /dev/null 2>&1; then
  echo 'error: tmux is not installed.'; exit
fi

# usage
usage() {
  echo "usage: ${0} -b | -r | -rm [session_name]"; exit
}

# backup
backup() {
  # total_session=`tmux list-sessions | wc -l`;
  session_names=`tmux list-sessions | awk -F: '{print $1}'`;
  # if [ -z $TMUX ]; then echo 'tmux is not running'; exit; fi
  if ! tmux list-sessions &>/dev/null; then echo 'tmux is not running'; exit; fi

  # creat backup dir
  if [ ! -d $backup_dir ]; then
    mkdir -p $backup_dir
  fi
  for name in $session_names; do
    if [[ $target && ($name != $target) ]]; then
      continue
    fi
    echo 'backup:' $name;
    session_size=$(tmux list-sessions | awk -F'[' '/^'$name': / {print $2}' | awk -F']' '{print $1}')
    echo "$session_size" >$backup_dir/$name.size

    # tmux list-windows -t leon | grep -v 'layout'
    tmux list-windows -t $name | grep -v 'layout' | sed 's/^\([^: ]*\): \(.*\) \[[0-9]*x[0-9]*\].*$/\1:\2/' | while read line; do
      # echo $line
      window=(`echo $line | awk -F: '{print $1,$2}'`) # array, window_index: ${window[0]} window_name: ${window[1]
      # echo 'back '${window} ${window[0]} ${window[1]}
      window_index=${window[0]}
      window_name=${window[1]}
      echo "$window_name" >$backup_dir/$name:$window_index-name

      for pane in $(tmux list-panes -t $name:$window_index | awk -F: '{print $1}'); do
        ##backup pane layout
        if [ $pane -gt 0 ]; then
          # tmux list-windows -t 1 | grep 'layout' | awk -F'layout: ' '/^ / {print $2}' | awk 'NR==3'
          pane_line=$(($window_index+1))
          tmux list-windows -t $name | awk -F'layout: ' '/^ / {print $2}' | awk "NR==$pane_line" >$backup_dir/$name:$window_index.layout
          # tmux list-windows -t $name | awk -F'\\[layout ' '/^'$window_index':/ {print $2}' | awk '{print $1}' | sed 's/\]$//' >$backup_dir/$name:$window_index.layout
        fi
        pane_full=$name:$window_index.$pane
        ##figure out the editing mode so we can select text in history
        mode_keys=$(tmux show-window-options -g | awk '/^mode-keys/ {print $2}')
        if [ "${mode_keys}" = 'emacs' ]; then
          tmux copy-mode -t $name:$window_index.$pane \; send-keys -t $name:$window_index.$pane 'M-<' 'C-Space' 'M->' 'C-e' 'M-w' \; save-buffer -b 0 $backup_dir/$pane_full \; delete-buffer -b 0
        elif [ "${mode_keys}" = 'vi' ]; then
          tmux copy-mode -t $name:$window_index.$pane \; send-keys -t $name:$window_index.$pane g Space G '$' Enter \; save-buffer -b 0 $backup_dir/$pane_full \; delete-buffer -b 0
        fi
        if [[ -f $backup_dir/$pane_full && (! -s $backup_dir/$pane_full) ]]; then
          rm $backup_dir/$pane_full
        fi
      done
    done
  done
}

# use prompt to get state of pane.
mimic_state() {
  prompt_regex="^.*@.*:"
  prompt_line=$(grep $(echo ${prompt_regex}) $backup_dir/$pane_full | tail -n 1 | sed 's/ \[git:.*$//')
  working_dir=$(printf "${prompt_line}" | cut -d: -f2 | cut -d\$ -f1 | cut -d\> -f1)

  tmux send-keys -t $pane_full "cd $working_dir" Enter
  echo $pane_full done.
}

# restore
restore() {
  # base-index
  base_index=0
  if [ -f ~/.tmux.conf ]; then
    if grep -v ^# ~/.tmux.conf | egrep 'base-index +[0-9]' >/dev/null; then
      base_index=$(grep -v ^# ~/.tmux.conf | egrep 'base-index +[0-9]' | awk -F'base-index ' '{print $2}')
    fi
  fi
  # restore sessions, windows, and panes
  for name in $(ls $backup_dir | grep -v '\.size$' | cut -d: -f1 | sort -du); do
    window_list=$(ls $backup_dir | awk -F: '/^'$name':/ {print $2}' | cut -d\. -f1 | sort -nu)
    window_list_rev=$(echo "$window_list" | sort -nr)
    num_windows=$(echo $window_list | wc -w)
    # echo $window_list_rev
    if [[ $target && ($name != $target) ]]; then
      continue
    fi
    echo 'restore session:' $name '('$num_windows')'

    # create session, and first window.
    # session_width=$(cut -d x -f 1 $backup_dir/$name.size)
    # session_height=$(($(cut -d x -f 2 $backup_dir/$name.size)+1))

    if ! tmux has-session -t $name > /dev/null 2>&1; then
      # tmux: unknown option -- x
      # tmux new-session -d -s $name -x $session_width -y $session_height
      tmux new-session -d -s $name
      # create additional windows if # of windows is > 1
      if [ $num_windows -gt 1 ] ;then
        echo "creating $(($num_windows-1)) additional windows ..."
        i=1
        while [ ${i} -lt $num_windows ]; do
          tmux new-window -d -a -t $name # echo $name:$base_index
          i=$((${i}+1))
        done
      fi
      # re-number the windows to reflect backed-up window number
      echo "re-numbering windows to reflect original scheme:"
      # always get $i to 1 regardless of base-index
      i=$(($num_windows+($base_index-1)))
      for window in $window_list_rev; do
        if [ ${i} -ne $window ]; then
          echo "$name:${i} -> $name:$window"
          tmux move-window -d -s $name:${i} -t $name:$window
        fi
        i=$((${i}-1))
      done

      # if windows had multiple panes, populate with proper number of panes
      for window in $window_list; do
        pane_list=$(ls $backup_dir | grep -v 'layout$' | awk -F\. '/^'$name':'$window'\./ {print $2}')
        num_panes=$(echo $pane_list | wc -w)
        # echo $pane_list $num_panes
        if [ $num_panes -gt 1 ]; then
          echo "adding panes to window, \"$name:$window\"."
          i=1
          while [ ${i} -lt $num_panes ]; do
            tmux split-window -d -v -t $name:$window.0
            rval=${?}
            if [ ${rval} -gt 0 ]; then
              echo "error: split-window with \"$name:$window\", compensating by re-arranging panes and trying again."
              tmux select-layout -t $name:$window tiled
              tmux split-window -d -v -t $name:$window.0
            fi
            i=$((${i}+1))
          done
          echo "applying saved layout to panes in window, \"$name:$window\"."
          layout=$(cat $backup_dir/$name:$window.layout)
          tmux select-layout -t $name:$window "$layout"
          for pane in $pane_list; do
            pane_full="$name:$window.$pane"
            tmux send-keys -t $pane_full "cat $backup_dir/$pane_full" Enter
            mimic_state
          done
        else
          pane_full="$name:$window.0"
          tmux send-keys -t $pane_full "grep -v -e 'strings you dont want to see' -e 'another string you dont want to see' $backup_dir/$pane_full | cat -s" Enter
          mimic_state
        fi
      done

      # re-name the windows
      echo "re-naming windows to original names:"
      for window in ${window_list_rev} ;do
        window_name=`cat $backup_dir/$name:$window-name`
        if [ "$window_name" != "$window" ] ;then
          echo "$name:$window -> $name:$window_name"
          tmux rename-window -t $name:$window "$window_name"
        fi
      done
    else
      echo '* session already exist:' 'tmux a -t' $name
    fi

  done
}

remove() {
  if [ ! $target ]; then
    usage;exit;
  fi
  tmux kill-session -t $target
  file_list=$(ls $backup_dir | grep $target':')
  if [ $file_list ]; then
    echo 'remove:' $file_list
    rm $backup_dir/$target':'*
    rm $backup_dir/$target.size
  fi
}

case $task in
  '-b')
    backup;;
  '-r') 
    restore;;
  '-rm')
    remove;;
  *)
  usage;; # if [ ! $task ]; then
esac

