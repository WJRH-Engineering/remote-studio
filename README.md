# Remote Studio

---

This is a collection of scripts that enable the WJRH remote 
broadcasting infrastructure. It consists of an Icecast server,
a daemonized liquidsoap script, and some utilities to manage them.

Each show that has the ability to broadcast remotely is given its
own Icecast mountpoint and password, DJs with the password can 
broadcast to this mountpoint at any time. A dedicated Liquidsoap 
script is responsible for switching between mountpoints based on
their timeslot. Once it determines which mountpoint should be
live, it repeats its signal to a dedicated mountpoint called
/remote-studio, which will get picked up by downstream
infrastructure.

Because Icecast does not provide a way to dynamically allocate
individually authenticated mountpoints, we must do this manually
by editing its config file and restarting it. This can quickly
become tedious, especially for large numbers of shows, and so 
it is desirable to automate this process with an external script.

The generate.py script fulfills this purpose. It reads show info
from an easy to edit data.csv file, and generates an xml file
describing a mountpoint for each show. It also generates
passwords for each of these mountpoints, and liquidsoap source
code that defines each mount point and its timeslot.

## Configuration

The remote studio is configured by a collection of several files
which are not version controlled and must be added manually.
They are:

- data.csv
- passwords.csv
- liq/passwords.liq 

### Data.csv

The data.csv file will be edited the most often. It is a CSV file
with 4 columns:

- name
- author
- start_time
- end_time
