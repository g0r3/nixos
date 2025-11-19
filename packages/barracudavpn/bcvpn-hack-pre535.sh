#!/usr/bin/env bash
# Dirty workaround for the "security" behavior of barracudavpn on NixOS.

err() { echo "Error: $&" 1>&2; exit 1; }

test -t 0 ||
    err 'Not in login shell!'

login="${1:?First argument must be your Barracuda username!}"
# Whouldn't it be nice, if we could specify the username in the config file?
config_folder="${2:-$HOME/.config/barracudavpn}"

[ -d "$config_folder" ] ||
    mkdir -p "$config_folder/ca" &&
    cp barracudavpn.conf "$config_folder/"

logpath=$(mktemp -t --suffix .log bcvpn.XXXXXX) ||
    err 'Cannot create logfile!'
trap "rm -f '$logpath'" EXIT ERR # Has sensitive data, ensure deleteion

# This is the real workaournd.
# baracudavpn somehow expects the `ip` command not to be a symlink or
# (presumably for "security" reasons), but is on NixOS, so we need to
# extract the calls to ip from the verbose output and run them manually
# (with sudo), but there's more prolems:
# 1) (fixed) barracudavpn prints the clear text server password in its
#    verbose output, so the logfile needs to be truncated/redacted ASAP.
# 2) Simple output redirect `...2>&1 >"$logpath"` seems to cause
#    barracudavpn to supress its verbose output completely (probably
#    in a misguided attempt to mitigate 1), so it needs to be in an
#    interactive shell, because it's a delicate flower.
# 3) closing/truncation of barracudavpn's input/output streams seems to
#    cause it to destory the tunnel, so the `script` command shouldn't
#    terminate.
# 4) sed/grep search patterns should not match themselves, `script` puts
#    them in the first log line.
# 5) while the first barracudavpn call is running, ctrl + C is ignored
# 6) proper quotation and namespacing is pretty tricky here
# 7) Ensure we're not connected, and barracudavpn hasn't messed up
#    resolv.conf rights as it is prone to do.
script "$logpath" --append --force --flush --command "
    sudo barracudavpn -p
    sudo chmod a+r /etc/resolv.conf
    sudo barracudavpn --verbose --start --config '$config_folder' --login '$login@barracuda.com'
    if ! grep -Eq 'Tunnel read[y]' '$logpath'; then
        echo 'Error: barracudavpn did not respond with ready tunnel' 1>&2
        exit 1
    fi
    cmds=\$(
        sed -n '/Connect state No error\./,$ p' '$logpath' |
            sed -n -E 's/^executing:\\s*([A-Za-z0-9 .\\/]+).*$/sudo ip \\1;/p'
    )
    echo > '$logpath'  # earliest we can truncate the logs
    printf 'About to run these commands:\\n--->>>\\n%s\\n<<<--- end\\n' \"\$cmds\"
    eval \"
        \$cmds
    \"
    sudo chmod a+r /etc/resolv.conf
    eval \"\${final_cmd:-ping -i 8 10.17.6.120;}\"
    sleep infinity  # keep i/o-streams open or barracudavpn will soil itself
"
