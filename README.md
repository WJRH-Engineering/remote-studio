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

## How to Use

The remote studio is configured by a collection of several files
which are not version controlled and must be added manually.
They are:

- data.csv
- passwords.csv
- liq/passwords.liq 

### Data.csv

The data.csv file will be edited the most often. It is a CSV file
with one row for each show on the schedule. It has 4 columns:

- name
- author
- start_time
- end_time

The name column corresponds to the shortname field given to the 
show by teal.cool. These should be unique for each show, and 
consist of only alphabetic characters and hyphons. No numbers,
punctuation, etc. If the show does not exist in teal, this field,
can be created by the user, so long as it abides by these
restrictions.

Author should be the email address of the person responsible for
the show. This is almost always going to be the main DJ.

Start_time and end_time are time interval expressions defined
by the liquidsoap scripting language. The syntax for these
expressions is explained here:

[https://www.liquidsoap.info/doc-dev/language.html#time-intervals](https://www.liquidsoap.info/doc-dev/language.html#time-intervals)

### Examples

```CSV
name,author,start_time,end_time
my-cool-show,winiarcc@lafayette.edu,3w10h,3w11h
my-other-show,winiarcc@lafayette.edu,4w20h,4w21h
```

The above data.csv file will produce two shows, my-cool-show
and my-other-show, both authored by winiarcc@lafayette.edu.
One will go from 10am to 11am on wednesdays, the other will
go from 8pm to 9pm on thursdays.

Once the data.csv file has been updated, the install command needs
be rerun for changes to take place. In the top level directory
of the repository, run:

```bash
sudo bash install
``` 
