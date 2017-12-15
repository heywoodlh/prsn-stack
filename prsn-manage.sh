#!/usr/bin/env bash

help() {
echo "Usage: $(basename "$0") [OPTION] -- psrn-stack cli management script
FlAGS:
    --help - show this help text
    start - start the prsn-stack
    stop - stop the prsn-stack"
}

start() {
docker start plex radarr sonarr nzbget
}

stop() {
docker stop plex radarr sonarr nzbget
}

if [[ -z "$1" ]]
then 
	help
fi

if [[ "$1" == '--help' ]]
then
	help
fi

if [[ "$1" == 'start' ]]
then 
	start
fi

if [[ "$1" == 'stop' ]]
then
	stop
fi
