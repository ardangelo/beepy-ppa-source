#!/bin/sh

if [ -f "/etc/beepy-fw-available" ]; then
	echo "Beepy firmware update available!"
	echo "    sudo update-beepy-fw"
	echo "Or \`sudo rm /etc/beepy-fw-available\` to hide this message"
fi
