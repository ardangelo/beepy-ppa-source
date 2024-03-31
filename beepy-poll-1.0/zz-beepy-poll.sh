#!/bin/bash

(

STARTUP_REASON_PATH="/sys/firmware/beepy/startup_reason"
BATTERY_PATH="/sys/firmware/beepy/battery_percent"

if [ ! -f "$STARTUP_REASON_PATH" ] \
 || [ $(cat "$STARTUP_REASON_PATH") != "rewake" ]; then
	exit 0
fi

# Check battery level
battery_percent=$(cat "$BATTERY_PATH")
if [ "$battery_percent" -lt "10" ]; then
	echo "Battery below 10%, shutting down and won't poll"
	poweroff
	exit 0
fi

echo "Poll as $USER. Any key to interrupt..."
echo

# Get poller PID
/usr/bin/beepy-poll | fold -w 40 &
beepy_poll_pid=$!

while IFS= read -n 1 -s key; do

	# Cancel rewake
	kill -USR1 $beepy_poll_pid

	echo "Polling canceled."
	exit 0
done

)
