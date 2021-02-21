# Remote Studio

---
The WJRH Remote Studio is a livestreaming service that allows DJs to do their shows remotely, without the need for physical access to the studio or broadcasting equipment. It was built in the fall of 2020 in order for the station to continue programming while the college was operating remotely, but it also aims to be a more general solution for operating any kind of show that cannot be done from inside the studio, such as on site coverage of concerts and sporting events, shows done on the Quad, shows done by alumni or other friends of the station, and shows done by students while the school is on break. The ultimate goal of the project is to improve the station's programming by its DJs with more flexibility and control regarding how and where their shows can be done. 

The service works by providing every show in the schedule with a mountpoint on a dedicated Icecast server, currently hosted on [remote.wjrh.org:8000](http://remote.wjrh.org:8000), which they can stream to at any time. A [Liquidsoap](https://www.liquidsoap.info/) script called the Scheduler listens to these mountpoints and selects zero or one of them to forward downstream, based on the current program schedule and their activity. The Scheduler will forward any stream that is available and streaming within its timeslot.

In addition, Remote Studio provides an RTMP to Icecast bridge, which allows users to use RTMP clients as well as Icecast ones. This notably includes [OBS](https://obsproject.com/) which is one of the most popular and easy to use multiplatform livestreaming clients, and is the recommended client for most DJs. 
For more information about setting up a remote show, see the [User Manual]()

## Scope

Remote Studio itself does not have any control over what gets played on the station. Instead, it simply generates an Icecast stream, which can be inserted into the final broadcast by downstream infrastructure. Currently, that responsibility belongs to a different liquidsoap script, called the [Broadcast Controller](TODO), which selects between the physical studio, remote studio, robo dj, and a backup playlist, based on their availability. 

## Getting Started


