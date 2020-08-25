#!/usr/bin/env sh
trap "update" USR1
pgrep -f sxmo_statusbar.sh | grep -v $$ | xargs kill -9

update() {
	# In-call.. show length of call
	CALLINFO=" "
	if pgrep -f sxmo_modemcall.sh; then
		NOWS="$(date +"%s")"
		CALLSTARTS="$(date +"%s" -d "$(
			grep -aE 'call_start|call_pickup' "$XDG_CONFIG_HOME"/sxmo/modem/modemlog.tsv |
			tail -n1 |
			cut -f1
		)")"
		CALLSECONDS="$(echo "$NOWS" - "$CALLSTARTS" | bc)"
		CALLINFO=" ${CALLSECONDS}s "
	fi

	# W symbol if wireless is connect
	WIRELESS=""
	WLANSTATE="$(tr -d "\n" < /sys/class/net/wlan0/operstate)"
	if [ "$WLANSTATE" = "up" ]; then
		WIRELESS="W "
	fi
  
	# M symbol if modem monitoring is on & modem present
	MODEMMON=""
	pgrep -f sxmo_modemmonitor.sh && MODEMMON="M "

	# Battery pct
	PCT="$(cat /sys/class/power_supply/*-battery/capacity)"
	BATSTATUS="$(
		cat /sys/class/power_supply/*-battery/status |
		cut -c1
	)"

	# Volume
	AUDIODEV="$(sxmo_audiocurrentdevice.sh)"
	[ "$AUDIODEV" = "None" ] && VOL="" || VOL=$(echo "$AUDIODEV" | cut -c1 | tr L S)"$(
		amixer sget "$AUDIODEV" |
		grep -oE '([0-9]+)%' |
		tr -d ' %' |
		awk '{ s += $1; c++ } END { print s/c }'  |
		xargs printf %.0f
	)"

	# Time
	TIME="$(date +%R)"

	BAR="${CALLINFO}${MODEMMON}${WIRELESS}${VOL} ${BATSTATUS}${PCT}% ${TIME}"
	xsetroot -name "$BAR"
}

# E.g. on first boot justs to make sure the bar comes in quickly
update && sleep 1 && update && sleep 1

while :
do
	update
	sleep 30 & wait
done
