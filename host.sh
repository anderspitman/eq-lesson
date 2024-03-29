#!/bin/bash

#set -x

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

        for workerId in {1..4}
        do
                echo "Starting worker $workerId for $path"
                hostFileWorker $channel $path $workerId &
        done

        wait
}

function hostFileWorker {
        local channel=$1
        local path=$2
        local workerId=$3

        while true
        do
                curl -s -X POST -H "Authorization: Bearer $token" $rootChannel$channel --data-binary @$path

                if [ "$?" -ne "0" ]; then
                        sleep 1
                fi
        done
}

function receiveCurrentPage {

        while true
        do
                val=$(curl -s $rootChannel/set-current-page)
                printf $val > ./current_page.txt

                # consume the stale current-page value
                for workerId in {1..4}
                do
                        curl -s $rootChannel/current-page > /dev/null &
                done

                # broadcast new value
                printf "data: $(<./current_page.txt)\n\n" | curl -s $rootChannel/current-page?pubsub=true --data-binary @- &

                if [ "$?" -ne "0" ]; then
                        sleep 1
                fi
        done
}

hostFile / ./index.html &
hostFile /slide_deck.js ./slide_deck.js &
hostFile /slide_deck.css ./slide_deck.css &
hostFile /current-page ./current_page.txt &

# images
hostFile /meme.jpg ./meme.jpg &
hostFile /elder_uchtdorf.jpg ./elder_uchtdorf.jpg &
hostFile /qr.svg ./qr.svg &

receiveCurrentPage &

hostFile /presenter ./presenter.html &

wait
