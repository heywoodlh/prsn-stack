#!/usr/bin/env bash

#SET THESE VARIABLES!!!

##Timezone Region/City view https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for list of Timezones
TZ='Europe/London'
##Docker User GID/UID -- Get this by running `id <dockeruser>`
PGID=''
PUID=''


#OPTIONAL VARIABLES TO SET -- LEAVE THEM ALONE IF YOU AREN'T SURE

STACK_DIR="$(pwd)"
#Global variables for each docker container
MOVIE_DIR="$STACK_DIR/Movies"
TV_SHOWS="$STACK_DIR/TV-Shows"
NZB_DOWNLOADS_DIR="$STACK_DIR/Downloads"

#Plex Variables
PLEX_DIR="$STACK_DIR/PlexMediaServer"

#CouchPotato Variables
RADARR_DIR="$STACK_DIR/Radarr"

#Sonarr Variables
SONARR_DIR="$STACK_DIR/Sonarr"

#NZBGet Variables
NZBGET_DIR="$STACK_DIR/NZBGet"

mkdir "$MOVIE_DIR" "$TV_SHOWS" "$NZB_DOWNLOADS_DIR" "$PLEX_DIR" "$RADARR_DIR" "$SONARR_DIR" "$NZBGET_DIR"

if [[ "$PGID" == '' ]]
then 
	echo "Please set PGID Variable in $0"
	exit 1
fi

if [[ "$PUID" == '' ]]
then 
	echo "Please set PUID Variable in $0"
	exit 1
fi

if [[ "$TZ" == '' ]]
then 
	echo "Please set TZ Variable in $0"
	exit 1
fi

##Create docker network
docker network create -d bridge --subnet=172.18.0.0/16 --gateway 172.18.0.1 prsnstack

##docker-plex build steps
docker create --name=plex --net=host -e VERSION=latest -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$PLEX_DIR":/config -v "$TV_SHOWS":/data/tvshows -v "$MOVIE_DIR":/data/movies linuxserver/plex

##docker-radarr build steps
docker create --name=radarr -v "$RADARR_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads -v "$MOVIE_DIR":/movies -e TZ="$TZ" -e PGID="$PGID" -e PUID="$PUID" -p 7878:7878 --net prsnstack --ip 172.18.0.2 linuxserver/radarr

##docker-sonarr build steps
docker create --name sonarr -p 9090:9090 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$SONARR_DIR":/config -v "$TV_SHOWS":/tv -v "$NZB_DOWNLOADS_DIR":/downloads --net prsnstack --ip 172.18.0.3 linuxserver/sonarr

##docker-nzbget build steps
docker create --name nzbget -p 6789:6789 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$NZBGET_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads --net prsnstack --ip 172.18.0.4 linuxserver/nzbget

docker start plex
docker start radarr
docker start sonarr
docker start nzbget
