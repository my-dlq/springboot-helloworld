#!/bin/bash
succ=1
function check_dead_link(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]; then
            check_dead_link $1"/"$file $2
        elif [ "${file: 0-5 :5}" == ".yaml" ]; then
            echo $file
        fi
    done
}
echo "Start to check dead links."
check_dead_link deploy
check_dead_link src
if [ $succ -eq 0 ]; then
    echo "Found dead links, please find logs above."
    exit 1
fi || exit 0;