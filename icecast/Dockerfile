from alpine:latest
run apk add --no-cache icecast

copy ./icecast.xml /etc/icecast2/icecast.xml

run adduser -D icecastd
run mkdir -p /var/log/icecast2/ && mkdir -p /etc/icecast2
run chown -R icecastd /var/log/icecast2
run chown -R icecastd /etc/icecast2
run chown -R icecastd /usr/share/icecast

user icecastd

expose 8000

cmd icecast -c /etc/icecast2/icecast.xml
