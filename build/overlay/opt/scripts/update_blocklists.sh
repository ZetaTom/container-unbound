#!/bin/bash
UNBOUND_BLOCKLIST_DIR=/etc/unbound/filterlists

urls=(
	'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
)

mkdir -p "$UNBOUND_BLOCKLIST_DIR"

# download and convert blocklists
i=0
for url in "${urls[@]}"; do
	content=$(curl -s "$url")
	echo "$content" | sed -n 's/^0\.0\.0\.0 \([^ #]*\).*/local-zone: \1 always_null/p' > "${UNBOUND_BLOCKLIST_DIR}/${i}.conf"
	(( i=i+1 ))
done

# fix file permissions
chown -Rf unbound:unbound "$UNBOUND_BLOCKLIST_DIR"

# reload unbound
if [ "$1" != "-n" ]; then
	unbound-control reload_keep_cache
	if [[ $? -ne 0 ]]; then
		echo 'WARN: failed to reload unbound; restarting service.'
		supervisorctl restart unbound
	fi
fi

echo 'Updated blocklists.'
