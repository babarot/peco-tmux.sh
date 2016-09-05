#!/bin/bash
# Version: 0.0.1
# Date: 2016-09-05
# Author: b4b4r07
# License: MIT
# Note:
#   this script was heavily inspired by fzf-tmux

if ! type peco &>/dev/null; then
    echo "peco: command not found" >&2
    exit 1
fi

if [[ -z $TMUX_PANE ]]; then
    peco
    exit $?
fi

set -e

# Clean up named pipes on exit
id=$RANDOM
fifo1=/tmp/peco-fifo1-$id
fifo2=/tmp/peco-fifo2-$id
fifo3=/tmp/peco-fifo3-$id
cleanup() {
    rm -f $fifo1 $fifo2 $fifo3
}
trap cleanup EXIT SIGINT SIGTERM

mkfifo $fifo2
mkfifo $fifo3

if [[ -t 0 ]]; then
    # Error
    peco
else
    mkfifo $fifo1
    tmux split-window 'bash -c "peco <'$fifo1' >'$fifo2'; echo \$? >'$fifo3'"'
    cat <&0 >$fifo1 &
fi
cat $fifo2
[[ "$(cat $fifo3)" == '0' ]]
