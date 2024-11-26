#!/bin/bash
podman run \
	--detach \
	--name unbound \
	--memory 1G \
	--cpus 1 \
	--health-cmd "/usr/sbin/unbound-control stats" \
	--health-interval 1m \
	--restart on-failure \
	--label "io.containers.autoupdate=local" \
	--dns 1.1.1.1 \
	--publish 53:53/tcp \
	--publish 53:53/udp \
	--volume /media/data/services/volumes/unbound-config:/etc/unbound/custom:Z \
	localhost/unbound:latest
