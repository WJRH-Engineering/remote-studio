

# from docker.io/library/rust:latest as builder
# copy auth .
# run rustup target add x86_64-unknown-linux-musl
# run rustup update
# run cargo install --path . --target x86_64-unknown-linux-musl

# from docker.io/library/alpine:latest 
# copy --from=builder /usr/local/cargo/bin/auth /usr/bin/auth

# run rc-update add sshd default

# Install Liquidsoap

# run apk add --no-cache opam make m4 g++ linux-headers ffmpeg

# from docker.io/ocaml/opam:alpine

# run opam init --disable-sandboxing --yes
# run opam switch create 4.12.0 --yes
# run opam install depext --yes

# # run opam depext taglib mad lame vorbis cry samplerate liquidsoap.1.4.4 --yes
# run opam depext vorbis cry samplerate liquidsoap.1.4.4 --yes
# run opam install vorbis cry samplerate liquidsoap.1.4.4 --yes

# copy scheduler scheduler

# cmd /bin/sh

from docker.io/ocaml/opam:debian as builder

run opam init --disable-sandboxing --yes
run opam switch create 4.12.0 --yes
run opam install depext --yes

run sudo apt install -y libpcre3-dev
run opam depext vorbis cry samplerate lame taglib mad liquidsoap.1.4.4
run opam install vorbis cry samplerate lame taglib mad liquidsoap.1.4.4

cmd /bin/sh




