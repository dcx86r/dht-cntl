#!/bin/sh

if [ "$(pidof transmission-daemon)" ]; then
	CREDS=$(cat /<path>/<to>/<transmission_credentials>)
	TNUM=$(transmission-remote -n "$CREDS" --debug -st 2>&1 | sed -n '/{/p' \
	| grep -o "activeTorrentCount\":[0-9]" | cut -d ':' -f2)
	ON=$(transmission-remote -n "$CREDS" -si | sed -n '/Dist.*/p' | grep -o "Yes")

	if [ "$TNUM" -eq "0" ]; then
		if [ "$ON" ]; then
			transmission-remote -n "$CREDS" --no-dht --no-pex 2>&1 \
			| sed -n 's/^.*\s//p' | tr -d '\n' >> /var/log/dht-log 
			echo " - DHT Off at $(date)" >> /var/log/dht-log
		fi
	else
		if [ -z "$ON" ]; then
			transmission-remote -n "$CREDS" --dht --pex 2>&1 \
			| sed -n 's/^.*\s//p' | tr -d '\n' >> /var/log/dht-log
			echo " - DHT On at $(date)" >> /var/log/dht-log
		fi
	fi
fi