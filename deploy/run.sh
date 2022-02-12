#!/bin/bash
succ=1
function check_dead_link(){
    for file in `ls $1`
    do
        echo file
        if [ -d $1"/"$file ]; then
            echo $1"/"$file $2
        elif [ "${file: 0-5 :5}" == ".yaml" ]; then
            echo $file
            succ=0
        fi
    done
}
echo "Start to check dead links."
if [ $succ -eq 0 ]; then
    echo "Found dead links, please find logs above."
    exit 1
fi || exit 0;