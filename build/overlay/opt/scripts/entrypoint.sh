#!/bin/bash
UNBOUND_CONFIG_FILE=/etc/unbound/unbound.conf
UNBOUND_ANCHOR_FILE=/etc/unbound/root.key
UNBOUND_ROOT_HINTS=/etc/unbound/root.hints
UNBOUND_ICANN_BUNDLE=/etc/unbound/icannbundle.pem

# check and download ICANN bundle
if [[ ! -f "$UNBOUND_ICANN_BUNDLE" ]]; then
	curl -so "$UNBOUND_ICANN_BUNDLE" 'https://data.iana.org/root-anchors/icannbundle.pem'
fi

# check and download root hints
if [[ ! -f "$UNBOUND_ROOT_HINTS" ]]; then
	curl -so "$UNBOUND_ROOT_HINTS" 'https://www.internic.net/domain/named.root'
fi

# generate necessary certificates
if [[ ! -f /etc/unbound/unbound_control.pem || ! -f /etc/unbound/unbound_server.pem ]]; then
	unbound-control-setup
fi

# generate root anchor key
unbound-anchor -a "$UNBOUND_ANCHOR_FILE"

# fix permissions
chown -Rf unbound:unbound /etc/unbound
chmod -R 644 /etc/unbound/{*.conf,custom}

# download initial blocklists
/opt/scripts/update_blocklists.sh -n

if [ $# -eq 0 ]; then
	exec supervisord -n -c /etc/supervisord.conf
else
	exec $@
fi
