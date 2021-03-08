# Remote Studio

---
The WJRH Remote Studio is a livestreaming service that allows DJs to do their shows remotely, without the need for physical access to the studio or broadcasting equipment. It was built in the fall of 2020 in order for the station to continue programming while the college was operating remotely, but it also aims to be a more general solution for operating any kind of show that cannot be done from inside the studio, such as on site coverage of concerts and sporting events, shows done on the Quad, shows done by alumni or other friends of the station, and shows done by students while the school is on break. The ultimate goal of the project is to improve the station's programming by providing its DJs with more flexibility and control regarding how and where their shows can be done. 

The service works by providing every show in the schedule with a mountpoint on a dedicated Icecast server, currently hosted on [remote.wjrh.org:8000](http://remote.wjrh.org:8000), which they can stream to at any time. A [Liquidsoap](https://www.liquidsoap.info/) script called the Scheduler listens to these mountpoints and selects zero or one of them to forward downstream, based on the current program schedule and their activity. The Scheduler will forward any stream that is available and streaming within its timeslot.

In addition, Remote Studio provides an RTMP to Icecast bridge, which allows users to use RTMP clients as well as Icecast ones. This notably includes [OBS](https://obsproject.com/) which is one of the most popular and easy to use multiplatform livestreaming clients, and is the recommended client for most DJs. 
For more information about setting up a remote show, see the [User Manual](https://github.com/WJRH-Engineering/remote-studio/blob/master/user-manual.md)


## Scope

Remote Studio itself does not have any control over what gets played on the station. Instead, it simply generates an Icecast stream, which can be inserted into the final broadcast by downstream infrastructure. Currently, that responsibility belongs to a different liquidsoap script, called the [Broadcast Controller](TODO), which selects between the physical studio, remote studio, robo dj, and a backup playlist, based on their availability.

Remote Studio is also not a schedule manager. It cannot write to or modify the schedule in any way, and expects this to be done entirely by external software, or manually if necessary. For convenience, the repository includes a set of scripts in the `tools` directory to help with writing schedules and assigning mountpoints, but these are not considered to be a part of Remote Studio's functionality, and should ideally be replaced with something more sophisticated in the future.

## Components

Remote Studio is composed of several smaller services which run as docker containers, and are defined in a docker-compose.yml file. They are described briefly below.

### Icecast

A generic Icecast server. It provides mountpoints for users to stream to, and allows the scheduler to easily access them. Its configuration is modified to use an external authentication service (Auth) for sources instead of a password. This allows us to do things like assign a diferent password for each show and easily change them on the fly. 

### RTMP 

An Nginx server which can accept RTMP streams. Upon receiving a connection, it immediately starts an instance of ffmpeg, which transcodes the stream to mp3 over Icecast in real time and forwards it to the Icecast server.

### Auth

An http authentication service shared by the Icecast and RTMP servers. It compares incoming requests against a set of accepted show - password pairs, and returns a status code of 200 if it finds a match. It is currently written as an express application in javascript, but might be better as a python or rust application to improve image size and security.

### Redis

A key value store used exclusively by the Auth service to store show - password pairs. Using redis makes it easier for the init script to communicate these pairs to the auth service. Redis was added early on in the project because it was extremely convenient, but it is also a little awkward, and I think it would be worth removing it in the future in favor of storing passwords directly in the auth service.

### Scheduler

A liquidsoap script that switches between streams on the Icecast server based on the current schedule. The scheduler is configured with a list of show - timeslot pairs, where each show is a mountpoint on the Icecast server, and each timeslot is a string representing two times of the week, between which the show should play.

Immediately after the scheduler starts, it enters a setup state where it listens for configuration messages over telnet. In this state, an external script or administrator can add timeslots with the `timeslot.add` command, set configuration variables with the `config.set` command, or otherwise modify the script's behavior. Once the scheduler has been configured, the `start` command can be used to put it into an active state, where it locks in its settings and starts listening for shows and streaming. Once in the active state, the scheduler can only be modified by resetting it and re-sending the configuration commands. 

### Init

A python script that runs after the rest of the services have started. It is responsible for collecting data about the schedule and using it to configure the other services. Currently it sends show and password data to the auth service, timeslot data and configuration settings to the scheduler, and the start signal responsible for putting the scheduler into the active state. Users interested in modifying Remote Studio's behavior beyond what is possible with the config file alone should consider writing a custom init script.

## Running an Instance

It is relatively straightforward to run your own instance of Remote Studio, which can be useful for debugging or trying out new features. It requires only a computer with docker and docker-compose installed, and the ports 8000 and 1935 available. The included `docker-compose.yml` file is built for testing on a local machine, and can be run with the commands `sudo docker-compose up` and `sudo docker-compose down`.
