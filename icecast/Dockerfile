FROM debian:latest
RUN apt-get update 
RUN apt-get install -y icecast2

RUN useradd icecastd
RUN chown -R icecastd /var/log/icecast2
RUN chown -R icecastd /etc/icecast2

EXPOSE 8000

CMD icecast2 -c /etc/icecast2/icecast.xml
