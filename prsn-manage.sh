#!/usr/bin/env bash

help() {
echo "Usage: $(basename "$0") [OPTION] -- psrn-stack cli management script
FlAGS:
    --help - show this help text
    start - start the prsn-stack
    stop - stop the prsn-stack
    update - update the prsn-stack containers"
}

start() {
docker start plex radarr sonarr nzbget
}

stop() {
docker stop plex radarr sonarr nzbget
}

update() {
source var.txt

docker pull linuxserver/plex > /dev/null
docker pull linuxserver/radarr > /dev/null
docker pull linuxserver/sonarr > /dev/null
docker pull linuxserver/nzbget > /dev/null

echo "Updating Plex"
docker stop plex
docker rm -f plex
docker create --name=plex -e VERSION=latest -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$PLEX_DIR":/config -v "$TV_SHOWS":/data/tvshows -v "$MOVIE_DIR":/data/movies --net prsnstack --ip 172.18.0.2 -p 32400:32400 -p 32400:32400/udp -p 32469:32469 -p 32469:32469/udp -p 5353:5353/udp -p 1900:1900/udp linuxserver/plex


echo "Updating Radarr"
docker stop radarr
docker rm -f radarr
docker create --name=radarr -v "$RADARR_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads -v "$MOVIE_DIR":/movies -e TZ="$TZ" -e PGID="$PGID" -e PUID="$PUID" -p 7878:7878 --net prsnstack --ip 172.18.0.3 linuxserver/radarr


echo "Updating Sonarr"
docker stop sonarr
docker rm -f sonarr
docker create --name sonarr -p 0.0.0.0:8989:8989 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$SONARR_DIR":/config -v "$TV_SHOWS":/tv -v "$NZB_DOWNLOADS_DIR":/downloads --net prsnstack --ip 172.18.0.4 linuxserver/sonarr


echo "Updating NZBGet"
docker stop nzbget
docker rm -f nzbget
docker create --name nzbget -p 6789:6789 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$NZBGET_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads --net prsnstack --ip 172.18.0.5 linuxserver/nzbget

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

if [[ "$1" == 'update' ]]
then 
	update
fi
