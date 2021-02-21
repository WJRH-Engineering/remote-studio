<!-- title: WJRH Remote Broadcasting Manual -->
<!-- author: Connor Winiarczyk, Hayden Dodge -->

<div style="display: flex; align-items: center; margin-bottom: 2rem;">
<img src="http://localhost:5000/logo.png" style="width: 10rem;"></img>

<div style="margin-left: 1rem;">
	<h1>Remote Broadcasting Manual</h1>
	<h3>Version 1.0</h3>
</div>
</div>


WJRH is currently in the process of expanding its broadcasting infrastructure to include shows hosted remotely over the internet. The goal of this new system is to provide a way for live programming to continue during 2020 Coronavirus restrictions, as well as to provide more flexibility in the future for things like alumni shows, special events, and live programming during the College's breaks. This document provides instructions for setting up a remote broadcast, as well as a high level overview of how the system works.

Because the quality of free audio software is inconsistent, and the needs of remote DJs are diverse and often unpredictable, the Remote Broadcasting System aims to be as flexible as possible in terms of the broadcasting clients it will work with. At the moment, it accepts two of the most commonly used live streaming protocols: 
[RTMP](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol),
which is used by services like Twitch, Youtube, Facebook Live, and similar sites, and
[Icecast](https://icecast.org/),
an open source protocol commonly used for music livestreaming and internet radio.

Any broadcasting software that is capable of using either of these protocols can be used to host a remote show. A list of some of the most popular ones is included below: 

|Client|Platform|Protocol|
|:----|:----|:---|
|[OBS](https://obsproject.com/)|Windows, Mac, Linux|RTMP|
|[Mixxx](https://www.mixxx.org/)|Windows, Mac, Linux|Icecast|
|[BUTT](https://www.cloudrad.io/butt-broadcasting/)|Windows, Mac, Linux|Icecast|
|[Audio Hijack](https://rogueamoeba.com/audiohijack/)|Mac|Icecast|
|[LadioCast](https://apps.apple.com/us/app/ladiocast/id411213048?mt=12)|Mac|Icecast|
|[iziCast](https://izicast.de/)|iOS|Icecast|
|[CoolMic](https://coolmic.net/)|Android|Icecast|
 
Of these, OBS has the best balance of features, ease of use, and platform compatibility, and so it is the recommended client for most users and setups. This manual will primarily focus on using OBS to broadcast over RTMP, but many other setups are possible which may work better for the needs of a specific show, and experimentation is encouraged.

<p style="page-break-before: always"></p>

# Getting Started: The Simplest Setup with OBS

The easiest way to start broadcasting is by using OBS to stream your show over RTMP. This is a very similar process to setting up a livestream over a service like youtube or twitch. It requires very little setup, and will work on any operating system. 

## Install OBS

OBS, or Open Broadcaster Software, is a completely free and open source tool for video recording and livestreaming. It is by far the most popular livestreaming client, and it is one of the few available on Windows, Mac, and Linux. OBS can be installed from their website at [https://obsproject.com/](https://obsproject.com/) by clicking on the link corresponding to your operating system.

Note: Mac users will need to be running OSX 10.13 (High Sierra) or above, if your Mac is not currently up to date, you will need to either update to the latest operating system, or try one of the other methods.

## Enter Stream Key

Once OBS is installed, you will need to to tell it which livestreaming service to use before you can start broadcasting. You can set this by navigating to the Stream section in the File > Settings menu. Set the service to Custom, and set the server to `rtmp://remote.wjrh.org/broadcast` as shown below.

Your stream key will be unique to your show, and will be sent to you by the program manager. It consists of two parts: an abbreviated version of your show name, which is referred to as your mountpoint, and a randomly generated, 5 character password. Stream keys will always take the form `<mountpoint>?password=<password>`. In the example below, the mountpoint is `example-show`, and the password is `ABCDE`.


<img src="http://localhost:5000/screenshots/streamkey.png" style="width: 95%; margin-left: auto; margin-right: auto;"></img>

## Add Sources

OBS has access to a wide range of audio sources, which include microphones, desktop audio, local media files, external audio devices, and more. These sources can be mixed with a series of faders in much the same way as a physical sound board, giving OBS users access to a large number of potential audio setups.

For most DJs, a setup consisting of a desktop audio source and a single microphone will be sufficient. This is considered the most basic setup, and it is the easiest way to start hosting a traditional radio show. Music can be played through any media player on your computer and captured through your desktop audio input. Guests can also join your shows through Voice Over IP programs like Zoom or Discord, with their audio being captured by the desktop audio source in the same way.

### Mac Users:

The exact method for adding sources will vary depending on the operating system you are using. Most notably, Mac OS users will need to install additional 3rd party software before desktop audio can be captured. This is due to a limitation in the Mac OS audio drivers that prevents applications like OBS from directly accessing system audio outputs. The OBS website recommends the iShowU Audio Capture application for this purpose, and they provide an excellent tutorial on setting it up:

[https://obsproject.com/forum/resources/os-x-capture-audio-with-ishowu-audio-capture.505/](https://obsproject.com/forum/resources/os-x-capture-audio-with-ishowu-audio-capture.505/)

### Resources

The OBS website maintains a number of other guides and tutorials on how to use their software, and they are a great resource for getting familiar with the program. A couple of the most relevant ones are linked below:

OBS quickstart guide: [https://obsproject.com/wiki/OBS-Studio-Quickstart](https://obsproject.com/wiki/OBS-Studio-Quickstart)

OBS overview: [https://obsproject.com/wiki/OBS-Studio-Overview](https://obsproject.com/wiki/OBS-Studio-Overview)

wiki: [https://obsproject.com/wiki/](https://obsproject.com/wiki/)

## Start Streaming

Once your OBS is set up with both your stream key and sources, you are ready to  begin streaming. This can be done with the Start Streaming button in the bottom right corner of the interface, and once started, streams can be stopped just as easily with the same button. 

The easiest way to verify that you stream is working is by checking the following website: [http://remote.wjrh.org:8000/](http://remote.wjrh.org:8000/) which will show a list of all currently active shows. If your show appears here, then the Remote Broadcasting System is successfully receiving your stream. Each of these streams can be listened to individually with their own unique URL. These will always take the form `http://remote.wjrh.org:8000/<mountpoint>`

In the example below, we can see that the show "Black Coffee" is currently streaming, and we could listen to it with the url `http://remote.wjrh.org:8000/black-coffee`. Listening to your show in this way is a great way to test your audio setup before going live. Although it is important to note that there is a significant delay, approximately 10 seconds, between the audio being streamed and the audio coming through the mountpoint.

![](http://localhost:5000/screenshots/icecast-status.png)

### Going Live

If you are signed up for a timeslot with WJRH, then all you need to do to broadcast your show live on air is to start streaming to your mountpoint at any point during your timeslot. The audio from your stream will automatically be repeated both on air and on the website. At the moment, there is no indication of this on the client side, and so the best way to verify that you are on air is simply to tune in and see if you can hear yourself, using either a radio (if in range) or the website ([www.wjrh.org](http://www.wjrh.org)).

Shows can either be ended manually by stopping the stream, or automatically by waiting until the end of the timeslot. If a show reaches the end of its timeslot without ending, then the system will simply stop repeating that stream, and either switch to the next show in the schedule, or return to the Robo DJ. If a show is live, but streaming silence, then the system will automatically detect this and switch back to Robo DJ after a set period of time.

DJs are free to stream to their mountpoint at any time, even outside of their show's timeslot. If desired, this mountpoint can be shared with others and treated like a personal internet radio station, with the only  restriction being that it must comply with FCC regulations whenever it is on air.

<div style="page-break-after: always;"></div>

# Alternative Clients

While OBS is the officially recommended client for remote broadcasting, it may not be the best solution for every show. Fortunately Icecast supports a number of other broadcasting clients, any of which can be used instead of OBS to remotely host shows. Icecast maintains a list of some of the best ones on their website: [https://icecast.org/apps/](https://icecast.org/apps/)

Connecting to the Remote Broadcasting System is slightly different with these clients than it is with OBS. Instead of a stream key, Icecast clients will usually ask for an address, port, mountpoint, user, and password. In this case, the address is `remote.wjrh.org`, port is always `8000`, user is the word `source`, and the mountpoint and password will correspond to those used in your OBS streamkey, and will also be provided by the program manager.

For example: If your OBS streamkey is `example-show?password=ABCDE` as it is in the example above, then you can connect an Icecast client to the same mountpoint with the following information:

|||
|:--|:--|
|address|remote.wjrh.org|
|port|8000|
|mountpoint|example-show|
|username|source|
|password|ABCDE|

A brief list of some recommended clients, along with some of their strengths and weaknesses, is included below.


## Broadcast Using This Tool (BUTT)

BUTT is an extremely simple, bare bones broadcasting client for icecast streams. In some sense, it is easier to use than OBS, but it lacks many of the features that make OBS a convenient, all in one solution to broadcasting. Most notably, BUTT does not include a built in mixer, meaning only one audio source can be broadcast at a time.  

If your show only uses one audio source, or if you intend on setting up your own mixer, either virtually through a third party program, or physically using your own sound board, then BUTT can be a great choice.  
 
## Mixxx

Mixxx is a fully featured, open source DJ software meant for live performances and internet radio. Conceptually, it lies on the opposite end of the spectrum from BUTT, with many more features than both BUTT and OBS, but also more complexity and a steeper learning curve. Mixxx is primarily aimed at both professional and amateur DJs who want access to a full DJ booth experience on their computers. It includes features like beat syncing, crossfading, sampling, turntable control, and more. It is recommended for any DJ wishing to experiment with a more professional setup, and it is also the most similar experience to being physically in the studio with a sound board.

[https://www.mixxx.org/](https://www.mixxx.org/)

Mixxx has its own user manual, which is linked below:

[https://www.mixxx.org/manual/latest/en/chapters/introduction.html](https://www.mixxx.org/manual/latest/en/chapters/introduction.html)

## Audio Hijack 

Audio Hijack is a paid program for Mac OS, which some users may decide is a worthwhile alternative to the free software described above. It costs $60 and discounts are offered for educational licenses. Unlike OBS, Mixxx, and BUTT, Audio Hijack does not require Mac users to install 3rd party software to capture desktop audio. Instead, it installs custom audio drivers which not only allow for the automatic use of desktop audio, but let you treat individual applications as separate audio sources. This is tremendously useful when, for example, a guest or co-host is joining you over a program like zoom, and you would like to control their audio separate from the music. While this feature is possible using free software, it is much more difficult.

[https://rogueamoeba.com/audiohijack/](https://rogueamoeba.com/audiohijack/)

## LadioCast

Ladiocast is a simple audio mixer and broadcast tool for MacOS. It is a good  free alternative to OBS for those who do not wish to update their operating system. However, like OBS, it requires third party audio drivers to capture desktop audio correctly.

[https://apps.apple.com/us/app/ladiocast/id411213048?mt=12](https://apps.apple.com/us/app/ladiocast/id411213048?mt=12)

## Mobile Clients

Icecast clients also exist for iOS and Android, meaning shows can now be hosted from your phone. The Icecast website recommends iziCast and Backpack Studio for iOS, and either BroadcastMyself or Cool Mic for Android.

