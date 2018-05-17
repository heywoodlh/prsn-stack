#!/usr/bin/env bash

#SET THESE VARIABLES!!!

##Timezone Region/City view https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for list of Timezones
TZ='America/Denver'
##Docker User GID/UID -- Get this by running `id <dockeruser>`
PGID=''
PUID=''

#Set the below variables to false if there is a specific part of the stack that you would like to omit

DOCKER_PLEX='true'
DOCKER_NZBGET='true'
DOCKER_RADARR='true'
DOCKER_SONARR='true'


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


#DO NOT EDIT BELOW THIS LINE


mkdir "$MOVIE_DIR" "$TV_SHOWS" "$NZB_DOWNLOADS_DIR" "$RADARR_DIR" "$SONARR_DIR" "$NZBGET_DIR" >/dev/null 2>&1

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


echo "TZ=$TZ" >> var.txt
echo "PGID=$PGID" >> var.txt
echo "PUID=$PUID" >> var.txt
echo "TV_SHOWS=$TV_SHOWS" >> var.txt
echo "NZB_DOWNLOADS_DIR=$NZB_DOWNLOADS_DIR" >> var.txt
echo "PLEX_DIR=$PLEX_DIR" >> var.txt
echo "RADARR_DIR=$RADARR_DIR" >> var.txt
echo "SONARR_DIR=$SONARR_DIR" >> var.txt
echo "NZBGET_DIR=$NZBGET_DIR" >> var.txt

##Create docker network
docker network create -d bridge --subnet=172.50.0.0/16 --gateway 172.50.0.1 prsnstack

##docker-plex build steps
if [[ "$DOCKER_PLEX" == 'true' ]]
then
	docker pull linuxserver/plex
	docker create --name=plex -e VERSION=latest -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$PLEX_DIR":/config -v "$TV_SHOWS":/data/tvshows -v "$MOVIE_DIR":/data/movies --net prsnstack --ip 172.50.0.2 -p 32400:32400 -p 32400:32400/udp -p 32469:32469 -p 32469:32469/udp -p 5353:5353/udp -p 1900:1900/udp linuxserver/plex
	docker start plex
fi

##docker-radarr build steps

if [[ "$DOCKER_RADARR" == 'true' ]]
then
	docker pull linuxserver/radarr
	docker create --name=radarr -v "$RADARR_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads -v "$MOVIE_DIR":/movies -e TZ="$TZ" -e PGID="$PGID" -e PUID="$PUID" -p 7878:7878 --net prsnstack --ip 172.50.0.3 linuxserver/radarr
	docker start radarr
fi

##docker-sonarr build steps

if [[ "$DOCKER_SONARR" == 'true' ]]
then
	docker pull linuxserver/sonarr
	docker create --name sonarr -p 0.0.0.0:8989:8989 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$SONARR_DIR":/config -v "$TV_SHOWS":/tv -v "$NZB_DOWNLOADS_DIR":/downloads --net prsnstack --ip 172.50.0.4 linuxserver/sonarr
	docker start sonarr
fi

##docker-nzbget build steps
if [[ "$DOCKER_NZBGET" == 'true' ]]
then
	docker pull linuxserver/nzbget
	docker create --name nzbget -p 6789:6789 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$NZBGET_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads -v "$TV_SHOWS":/tvshows -v "$MOVIE_DIR":/movies --net prsnstack --ip 172.50.0.5 linuxserver/nzbget
	docker start nzbget
fi
