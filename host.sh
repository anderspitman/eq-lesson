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
        local workerId=$3

        while true
        do
                curl -X POST -H "Authorization: Bearer $token" $rootChannel$channel --data-binary @$path
                echo $workerId

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

                # consume the stale current-page value
                curl $rootChannel/current-page &

                # broadcast new value
                printf "data: $(<./current_page.txt)\n\n" | curl $rootChannel/current-page?pubsub=true --data-binary @- &

                if [ "$?" -ne "0" ]; then
                        sleep 1
                fi
        done
}

hostFile / ./index.html &
hostFile /slide_deck.js ./slide_deck.js &
hostFile /slide_deck.css ./slide_deck.css &
hostFile /current-page ./current_page.txt &

hostFile /meme.jpg ./meme.jpg 1 &
hostFile /meme.jpg ./meme.jpg 2 &
hostFile /meme.jpg ./meme.jpg 3 &
hostFile /meme.jpg ./meme.jpg 4 &

hostFile /elder_uchtdorf.jpg ./elder_uchtdorf.jpg 1 &
hostFile /elder_uchtdorf.jpg ./elder_uchtdorf.jpg 2 &
hostFile /elder_uchtdorf.jpg ./elder_uchtdorf.jpg 3 &
hostFile /elder_uchtdorf.jpg ./elder_uchtdorf.jpg 4 &

hostFile /qr.svg ./qr.svg 1 &
hostFile /qr.svg ./qr.svg 2 &
hostFile /qr.svg ./qr.svg 3 &
hostFile /qr.svg ./qr.svg 4 &

receiveCurrentPage &

hostFile /presenter ./presenter.html &

wait
