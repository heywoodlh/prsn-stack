## pcsn-stack

This repository contains scripts that will download, install and configure PlexMediaServer, CouchPotato, Sonarr and NZBGet using LinuxServer.io's Docker images.

### Requirements:

1. Docker must be installed (https://docs.docker.com/engine/installation/)

2. A non-root user should be able to use the Docker command (add the user to the Docker group)


### Installation:

Clone this repository:
`git clone https://github.com/heywoodlh/pcsn-stack.git`

Change directories:
`cd pcsn-stack`

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

CouchPotato will be accessible at: http://127.0.0.1:5050

Sonarr will be accessible at: http://127.0.0.1:8989

NZBGet will be accessible at: http://127.0.0.1:6789


### Docker NAT

A Docker network called pcsnstack is created in which all the containers will be able to use to communicate with one another. 

CouchPotato is on 172.0.0.2

Sonarr is on 172.0.0.3

NZBGet is on 172.0.0.4

In order to configure CP, Sonarr or NZBGet to connect to one another these NAT IP addresses will need to be used.


### Uninstalling:

Run the uninstall.sh script:
`./uninstall.sh`
