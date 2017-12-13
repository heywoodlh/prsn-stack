#!/usr/bin/env bash

echo "removing containers"
docker rm -f plex sonarr couchpotato nzbget

echo "removing local images for containers"
docker image rm linuxserver/plex linuxserver/couchpotato linuxserver/sonarr linuxserver/nzbget
