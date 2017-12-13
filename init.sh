#!/usr/bin/env bash

#Global variables for each docker container
MOVIE_DIR='Movies'
TV_SHOWS='TV-Shows'
NZB_DOWNLOADS_DIR='Downloads'
##Timezone Region/City view https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for list of Timezones
TZ='Europe/London'
##Docker User GID/UID -- Get this by running `id <dockeruser>`
PGID=''
PUID=''

#Plex Variables
PLEX_DIR='PlexMediaServer'

#CouchPotato Variables
COUCHPOTATO_DIR='CouchPotato'

#Sonarr Variables
SONARR_DIR='Sonarr'

#NZBGet Variables
NZBGET_DIR='NZBGet'

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

##docker-plex build steps
docker create --name=plex --net=host -e VERSION=latest -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$PLEX_DIR":/config -v "$TV_SHOWS":/data/tvshows -v "$MOVIE_DIR":/data/movies linuxserver/plex

##docker-couchpotato build steps
docker create --name=couchpotato -v "$COUCHPOTATO_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads -v "$MOVIE_DIR":/movies -e PGID="$PGID" -e PUID="$PUID"  -e TZ="$TZ" -p 5050:5050 linuxserver/couchpotato

##docker-sonarr build steps
docker create --name sonarr -p 8989:8989 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$SONARR_DIR":/config -v "$TV_SHOWS":/tv -v "$NZB_DOWNLOADS_DIR":/downloads linuxserver/sonarr

##docker-nzbget build steps
docker create --name nzbget -p 6789:6789 -e PUID="$PUID" -e PGID="$PGID" -e TZ="$TZ" -v "$NZBGET_DIR":/config -v "$NZB_DOWNLOADS_DIR":/downloads linuxserver/nzbget

docker start plex
docker start couchpotato
docker start sonarr
docker start nzbget
