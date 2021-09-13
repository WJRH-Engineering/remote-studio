FROM docker.io/ocaml/opam:alpine

WORKDIR haversiner

# Install dependencies
ADD haversiner.opam .
RUN opam pin add -yn haversiner . && \
    opam depext haversiner && \
    opam install --deps-only haversiner

# Build the app! Note: The chown is somehow necessary, as
# without it the `make build` command will fail with
# permission errors.
# We also need to take note of the dependencies from depext.
ADD . .
RUN sudo chown -R opam:nogroup . && \
    opam config exec make build && \
    opam depext -ln haversiner | egrep -o "\-\s.*" | sed "s/- //" > depexts
    
# Let's create the production image!
FROM alpine
WORKDIR /app
COPY --from=0 /home/opam/haversiner/_build/default/bin/main.exe haversiner.exe

# Don't forget to install the dependencies, noted from
# the previous build.
COPY --from=0 /home/opam/haversiner/depexts depexts
RUN cat depexts | xargs apk --update add && rm -rf /var/cache/apk/*

EXPOSE 3000
CMD ./haversiner.exe
