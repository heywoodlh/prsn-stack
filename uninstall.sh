#!/usr/bin/env bash

echo "removing containers"
docker rm -f plex radarr sonarr nzbget

echo "removing local images for containers"
docker image rm linuxserver/plex linuxserver/radarr linuxserver/sonarr linuxserver/nzbget

echo "removing prsnstack network"
docker network rm prsnstack
