#!/bin/bash
UNBOUND_TEMP_DIR=/tmp/filterlists
UNBOUND_BLOCKLIST_DIR=/etc/unbound/filterlists

urls=(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
    'https://raw.githubusercontent.com/mullvad/dns-blocklists/refs/heads/main/output/relay/relay_adblock.txt'
    'https://raw.githubusercontent.com/mullvad/dns-blocklists/refs/heads/main/output/relay/relay_privacy.txt'
)

mkdir -p "$UNBOUND_TEMP_DIR" "$UNBOUND_BLOCKLIST_DIR"

# download and convert blocklists
i=0
for url in "${urls[@]}"; do
    curl -s "$url" | sed -nr 's/^(0\.0\.0\.0)*[[:space:]*.]*(([[:alnum:]-]+\.)+[[:alpha:]]+).*/\2/p' | tr '[:upper:]' '[:lower:]' > "${UNBOUND_TEMP_DIR}/${i}.conf"
    (( i=i+1 ))
done

# format unique entries for unbound
awk '!x[$0]++' ${UNBOUND_TEMP_DIR}/*.conf | sed 's/.*/local-zone: & always_nxdomain/' > "${UNBOUND_BLOCKLIST_DIR}/unified.conf"
wc -l "${UNBOUND_BLOCKLIST_DIR}/unified.conf"

# remove artefacts
rm -rf ${UNBOUND_TEMP_DIR}

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
