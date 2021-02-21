# Remote Studio

---
The WJRH Remote Studio is a livestreaming service that allows DJs to do their shows remotely, without the need for physical access to the studio or broadcasting equipment. It was created in the fall of 2020 in order for the station to continue programming while the college was operating remotely, but it also aims to be a more general solution for operating any kind of show that cannot be done from inside the studio, such as on site coverage of concerts and sporting events, shows done on the Quad, shows done by alumni or other friends of the station, and shows done by students while the school is on break. The ultimate goal of the project is to improve the station's programming by its DJs with more flexibility regarding how and where there shows can be done. 

The service works by providing every show in the schedule with a mountpoint on a dedicated Icecast server, currently hosted on [remote.wjrh.org:8000](http://remote.wjrh.org:8000), which they can stream to at any time. A [Liquidsoap](https://www.liquidsoap.info/) script called the Scheduler listens to these mountpoints and selects zero or one of them to forward downstream, based on the current program schedule and their activity. 

decides based on their activity and the current program schedule

using any streaming software that supports the Icecast protocol. 
