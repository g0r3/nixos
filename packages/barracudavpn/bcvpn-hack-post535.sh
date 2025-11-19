#!/usr/bin/env bash
# Internal convenience wrapper for barracudavpn

login=${1:?First argument must be your Barracuda username!}
password=${2:?Second argument must be your Barracuda password - ideally via password-manager and subshell}

config_folder="${BCVPN_CONFIG_PATH:-$HOME/.config/barracudavpn}"

err() { echo "Error: $&" 1>&2; exit 1; }

mkdir -p "$config_folder/ca"
cp --update=none barracudavpn.conf "$config_folder/"

logpath=$(mktemp -t --suffix .log bcvpn.XXXXXX) ||
    err 'Cannot create logfile!'
trap "rm -f '$logpath'" EXIT ERR # Potentially has sensitive data, ensure deleteion

sudo barracudavpn --stop
sudo chmod a+r /etc/resolv.conf  # might have been left unreadable from a dirty exit
echo "$login" | grep -qE '@barracuda\.com$' ||
   echo WARNING: you probably want @barracuda.com at the end of "'$login'" 1>&2
sudo barracudavpn --verbose --start --config "$config_folder" \
  --login "$login" --serverpwd "$password" "$@" 2>&1 |
    tee "$logpath" &
for retry in {0..10}; do  # ToDo: find a better way, ideally, barracudavpn would not block
    if grep -Eq 'Tunnel read[y]' "$logpath"; then break; fi
    sleep 2
    if (( retry < 10 )); then continue; fi
    echo 'Error: barracudavpn did not respond with ready tunnel' 1>&2
    sudo barracudavpn --stop &
    exit 1
done
cmds=$(
    sed --quiet '/Connect state No error\./,$ p' "$logpath" |
        sed --quiet --regexp-extended 's@^executing:\s*([A-Za-z0-9 .\/]+).*$@sudo ip \1;@p'
)
echo > "$logpath"  # earliest we can truncate the logs
printf 'About to run these commands:\n--->>>\n%s\n<<<--- end\n' "$cmds"
eval "
    $cmds
"
sudo chmod a+r /etc/resolv.conf
eval "${BCVP_FINAL_CMD:-ping -i 8 10.17.6.120 | while read p; do printf '%(%H:%M:%S)T: %s\n' -1 \"\$p\"; done}"
