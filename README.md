## prsn-stack

This repository contains scripts that will download, install and configure PlexMediaServer, Radarr, Sonarr and NZBGet using LinuxServer.io's Docker images.



### Requirements:

1. Docker must be installed

2. A non-root user should be able to use the Docker command (add the user to the Docker group)

Install Docker and add the user to the docker group by using these commands on Ubuntu:
`sudo apt-get update; sudo apt-get install docker.io; sudo usermod -aG docker "$USER"`

Log out then back in to make sure that your user can run the docker command without permissions issues:
`docker ps`

Or you can follow Docker's instructions: (https://docs.docker.com/engine/installation/)


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


### Ports:

The Plex Server will be running on port 32400 of the local machine and will be accessible at: http://127.0.0.1:32400/web

Radarr will be accessible at: http://127.0.0.1:7878

Sonarr will be accessible at: http://127.0.0.1:8989

NZBGet will be accessible at: http://127.0.0.1:6789


### Docker NAT:

A Docker network called prsnstack is created in which all the containers will be able to use to communicate with one another. 

Plex is on 172.50.0.2

Radarr is on 172.50.0.3

Sonarr is on 172.50.0.4

NZBGet is on 172.50.0.5

In order to configure Radarr, Sonarr or NZBGet to connect to one another use the service name and port to connect (i.e. nzbget:6789). Because the containers are on the same network the hostname of the container will resolve to the internal IP address.

Thus:

plex => 172.50.0.2

radarr => 172.50.0.3

sonarr => 172.50.0.4

nzbget => 172.50.0.5


### Connect Services to Each Other:

Plex, Radarr, Sonarr and NZBGet will share multiple folders that will be created in the repository folder: 

./TV-Shows - Where TV shows will be downloaded

./Movies - Where movies will be downloaded

./Downloads - Where captured NZB files will be stored


#### 1. Configure NZBGet:

Log in to http://127.0.0.1:6789:

A prompt for NZBGet's username and password will appear. The default username is 'nzbget' and the default password is 'tegbzn6789'. 


Change the username and password:

Go to Settings > Security and change the 'Control Username' and 'Control Password' to whatever you would like. Scroll to the bottom of the page and press 'Save'. Reload NZBGet when it prompts to do so.


Configure your News Servers, RSS Feeds or other settings: 

Go into Settings and add the information for your News Servers, RSS Feeds, or other settings.


##### Configure categories:

The movies category path should be `/movies`.

The TV-show category path should be `/tvshows`.



#### 2. Configure Radarr:

Log in to http://127.0.0.1:7878


Change the Username and Password:

Go to Settings > General > Security. Under 'Authentication', 'None' will be the default value. Recommended change would be to 'Forms (Login Page)'. Enter in a new username and password that will be used to login. 


Connect to NZBGet:

Go to Settings > Download Client and click the large plus icon. Select NZBGet as your download client. Under Name type in "NZBGet". Change the value of "Host" to equal 'nzbget'. Change the username and password to reflect the username and password setup when configuring NZBGet. Press 'Test' to test your connection and then 'Save' if the test is successful.


Connect to Indexers: 

Go to Settings > Indexers to connect to whatever indexers you would like to use for downloading content.


Downloading content:

When adding a movie for the first time, you will need to set the 'Path' that it will download to. When adding the movie there will be an option for 'Path' that will say nothing. Press on that option and then select 'Add a different path'. Click the blue folder icon to browse the filesystem. Find the folder called movies and put select that. Now NZBGet will download movies from Radarr to that folder.



#### 3. Configure Sonarr:

Log in to http://127.0.0.1:8989


Change the Username and Password:

Go to Settings > General > Security. Under 'Authentication', 'None' will be the default value. Recommended change would be to 'Forms (Login Page)'. Enter in a new username and password that will be used to login. 


Connect to NZBGet:

OF note when connecting Sonarr to NZBGet: The steps are exactly the same as Radarr except for changing the category to 'Series' rather than the default.

Go to Settings > Download Client and click the large plus icon. Select NZBGet as your download client. Under Name type in "NZBGet". Change the value of "Host" to equal 'nzbget'. Change the username and password to reflect the username and password setup when configuring NZBGet. Press 'Test' to test your connection and then 'Save' if the test is successful.


Connect to Indexers: 

Go to Settings > Indexers to connect to whatever indexers you would like to use for downloading content.


Downloading content:

When adding a TV Show for the first time, you will need to set the 'Path' that it will download to. When adding the TV Show there will be an option for 'Path' that will say nothing. Press on that option and then select 'Add a different path'. Click the blue folder icon to browse the filesystem. Find the folder called 'tv' and put select that. Now NZBGet will download TV Shows from Sonarr to that folder.


#### 4. Configure Plex:

Log in to http://127.0.0.1:32400/web to log in to Plex. Follow the steps that Plex prompts with in order to login to your Plex account.

When adding a Plex library, add the 'Movies' directory as your movie folder, and the 'TV-Shows' directory for TV-Shows.


#### 5. Start PRSN-stack as a Systemd Service:

Edit the sample systemd service in `./lib/prsn-stack.service` and change the `User=myuser` to the user that set up the docker containers.

Copy `./lib/prsn-stack.service` to `/etc/systemd/system/prsn-stack.service`:

`sudo cp lib/prsn-stack.service /etc/systemd/system/prsn-stack.service`

Then enable the service to start up on boot:

`sudo systemctl enable prsn-stack.service`

If the docker containers are not running, start the service:

`sudo systemctl start prsn-stack.service`


### Upgrade:

Run `uninstall.sh` and then re-run `init.sh`:
`./uninstall.sh`
`./init.sh`

Since the Docker containers store their configuration on the host they are on, destroying the containers shouldn't be a problem. Once `init.sh` has run again the containers will reuse whatever configuration was being used before. The only time they will not re-use the same configuration would be if you deleted the directories for each container.



### Uninstalling:

Run the uninstall.sh script:
`./uninstall.sh`

Remove the directories for each container:
`rm -rf Plex Radarr Sonarr NZBGet`
