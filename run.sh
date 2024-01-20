#!/bin/bash
podman run \
	--detach \
	--name unbound \
	--restart on-failure \
	--label "io.containers.autoupdate=local" \
	--dns 1.1.1.1 \
	--publish 53:53/tcp \
	--publish 53:53/udp \
	--volume $PWD/unbound:/etc/unbound/custom:Z \
	localhost/unbound:latest
