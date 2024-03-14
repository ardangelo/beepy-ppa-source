#!/bin/bash

(

if [ $(cat /sys/firmware/beepy/startup_reason) != "rewake" ] \
 || systemctl is-active beepy-poll.service >/dev/null; then
	exit 0
fi

echo "Running Beepy poller. Press any key to interrupt..."
echo

# Start journalctl monitor
journalctl --output cat -u beepy-poll -f | fold -w 40 &
journalctl_pid=$!

# Start poller service
sudo systemctl start beepy-poll &

while IFS= read -n 1 -s key; do

	# Get poller PID
	beepy_poll_pid=""
	while [ -z "$beepy_poll_pid" ]; do
		echo "Canceling (waiting for poll PID)..."
		beepy_poll_pid=$(journalctl -u beepy-poll -n10 | grep 'beepy-poll\[' | tail -n1 | cut -d '[' -f 2 | cut -d ']' -f 1)
		sleep 1
	done

	# Cancel rewake
	sudo kill -USR1 $beepy_poll_pid

	# Cancel monitor
	kill $journalctl_pid

	echo "Polling canceled."
	exit 0
done

)
