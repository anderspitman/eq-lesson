#!/bin/bash

set -x

rootChannel=$1
token="dummytoken"
if [ $2 ]
then
        token=$2
fi

# kill all child processes on exit
trap 'kill $(jobs -p)' EXIT

function hostFile {
        local channel=$1
        local path=$2

        while true
        do
                curl -X POST -H "Authorization: Bearer $token" $rootChannel$channel --data-binary @$path

                if [ "$?" -ne "0" ]; then
                        sleep 1
                fi
        done
}

function receiveCurrentPage {

        while true
        do
                val=$(curl $rootChannel/set-current-page)
                printf $val > ./current_page.txt

                printf "data: $(<./current_page.txt)\n\n" | curl $rootChannel/current-page?pubsub=true --data-binary @- &

                if [ "$?" -ne "0" ]; then
                        sleep 1
                fi
        done
}

hostFile / ./index.html &
hostFile /index.js ./index.js &
hostFile /current-page ./current_page.txt &
hostFile /meme.jpg ./meme.jpg &
hostFile /qr.svg ./qr.svg &
receiveCurrentPage &

wait
