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

# Start poller service
while true; do
	if ! systemctl --user start beepy-poll; then
		systemctl --user stop beepy-poll
		echo "Restarting poller service..."
		sleep 1
	else
		break
	fi
done

echo "Poll as $USER. Press key to interrupt..."
echo

# Get poller PID
beepy_poll_pid=""
while true; do
	beepy_poll_pid=$(journalctl --user -u beepy-poll -n10 | grep 'beepy-poll\[' | tail -n1 | cut -d '[' -f 2 | cut -d ']' -f 1)
	if [ ! -z "$beepy_poll_pid" ]; then
		break
	fi
	echo "Waiting for poll PID..."
	sleep 1
done

# Start journalctl monitor
journalctl --output cat --user -u beepy-poll -f | fold -w 40 &
journalctl_pid=$!

while IFS= read -n 1 -s key; do

	# Cancel rewake
	kill -USR1 $beepy_poll_pid

	# Cancel monitor
	kill $journalctl_pid

	echo "Polling canceled."
	exit 0
done

)
