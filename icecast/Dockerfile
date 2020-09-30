FROM debian:latest
RUN apt-get update 
RUN apt-get install -y icecast2

RUN useradd icecastd
RUN chown -R icecastd /var/log/icecast2
RUN chown -R icecastd /etc/icecast2

EXPOSE 8000

# INIT Python script
RUN apt-get -y install python
RUN apt-get -y install python-pip
RUN pip install redis

COPY . .

# CMD python init.py && icecast2 -c /etc/icecast2/icecast.xml
CMD icecast2 -c /etc/icecast2/icecast.xml
# CMD cat /etc/icecast2/icecast.xml
