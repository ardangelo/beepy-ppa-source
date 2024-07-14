#!/bin/sh

if [ -f "/etc/emate-fw-available" ]; then
	echo "emate firmware update available!"
	echo "    sudo update-emate-fw"
	echo "Or \`sudo rm /etc/emate-fw-available\` to hide this message"
fi
