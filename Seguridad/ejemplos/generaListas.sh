#!/bin/zsh

for i in $(seq 1000);
do
    VARR=""
    for j in $(seq 4);
    do
        VARR=${VARR}"."$((RANDOM%254))
    done

    IP=$(echo ${VARR} |sed -e "s/^.//") 
    echo ${IP}
done
