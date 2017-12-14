## prsn-stack

This repository contains scripts that will download, install and configure PlexMediaServer, Radarr, Sonarr and NZBGet using LinuxServer.io's Docker images.

### Requirements:

1. Docker must be installed (https://docs.docker.com/engine/installation/)

2. A non-root user should be able to use the Docker command (add the user to the Docker group)


### Installation:

Clone this repository:
`git clone https://github.com/heywoodlh/prsn-stack.git`

Change directories:
`cd prsn-stack`

#### Configure the init script: 
Open the init.sh script in a text editor. 

Edit the PGID, PUID and TZ variables: 

PGID is the group ID of the Docker user. This can be found by running `id "$USER"`

PUID is the user ID of the Docker user. This can be found by running `id "$USER"`

TZ is the timezone that the Docker containers will use. You can find a list of Unix time zones here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones



Run the init script:
`./init.sh`


### Ports

The Plex Server will be running on port 32400 of the local machine and will be accessible at: http://127.0.0.1:32400/web

Radarr will be accessible at: http://127.0.0.1:7878

Sonarr will be accessible at: http://127.0.0.1:8989

NZBGet will be accessible at: http://127.0.0.1:6789


### Docker NAT

A Docker network called prsnstack is created in which all the containers will be able to use to communicate with one another. 

Plex is on 172.18.0.2

Radarr is on 172.18.0.3

Sonarr is on 172.18.0.4

NZBGet is on 172.18.0.5

In order to configure Radarr, Sonarr or NZBGet to connect to one another use the service name and port to connect (i.e. nzbget:6789). Because the containers are on the same network the hostname of the container will resolve to the internal IP address.

Thus:

plex => 172.18.0.2

radarr => 172.18.0.3

sonarr => 172.18.0.4

nzbget => 172.18.0.5


### Uninstalling:

Run the uninstall.sh script:
`./uninstall.sh`
