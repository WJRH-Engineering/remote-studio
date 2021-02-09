from alpine:latest
run apk add --no-cache icecast

run adduser -D icecastd
run mkdir -p /var/log/icecast/ && mkdir -p /etc/icecast

copy ./icecast.xml /etc/icecast/icecast.xml
copy ./web /etc/icecast/web
copy ./admin /etc/icecast/admin

run chown -R icecastd /var/log/icecast
run chown -R icecastd /etc/icecast
run chown -R icecastd /usr/share/icecast

user icecastd

expose 8000

cmd icecast -c /etc/icecast/icecast.xml
