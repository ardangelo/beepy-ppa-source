#!/bin/bash

(

STARTUP_REASON_PATH="/sys/firmware/beepy/startup_reason"
BATTERY_PATH="/sys/firmware/beepy/battery_percent"

if [ ! -f "$STARTUP_REASON_PATH" ] \
 || [ $(cat "$STARTUP_REASON_PATH") != "rewake" ] \
 || systemctl is-active beepy-poll.service >/dev/null; then
	exit 0
fi

# Check battery level
battery_percent=$(cat "$BATTERY_PATH")
if [ "$battery_percent" -lt "10" ]; then
	echo "Battery below 10%, shutting down and won't poll"
	poweroff
	exit 0
fi

echo "Beepy polling as $USER. Press key to interrupt..."
echo

# Start journalctl monitor
journalctl --output cat --user -u beepy-poll -f | fold -w 40 &
journalctl_pid=$!

# Start poller service
systemctl --user start beepy-poll &

while IFS= read -n 1 -s key; do

	# Get poller PID
	beepy_poll_pid=""
	while [ -z "$beepy_poll_pid" ]; do
		echo "Canceling (waiting for poll PID)..."
		beepy_poll_pid=$(journalctl --user -u beepy-poll -n10 | grep 'beepy-poll\[' | tail -n1 | cut -d '[' -f 2 | cut -d ']' -f 1)
		sleep 1
	done

	# Cancel rewake
	kill -USR1 $beepy_poll_pid

	# Cancel monitor
	kill $journalctl_pid

	echo "Polling canceled."
	exit 0
done

)
