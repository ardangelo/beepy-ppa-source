#!/bin/bash

set -e

for prod in beepy-fw-* beepy-gomuks-* beepy-kbd-* beepy-poll-* \
	beepy-symbol-overlay-* beepy-tmux-menus-* sharp-drm-*; do

	if [ ! -d "$prod" ]; then
		continue
	fi
	pushd $prod

	if [ -d module ]; then
		pushd module && make clean ||:; popd
	fi

	CXX=arm-linux-gnueabihf-g++ \
	OBJCOPY=arm-linux-gnueabihf-objcopy \
		dpkg-buildpackage -us -uc --host-arch armhf

	if [ -d module ]; then
		pushd module && make clean ||:; popd
	fi

	CXX=aarch64-linux-gnu-g++ \
	OBJCOPY=aarch64-linux-gnu-objcopy \
		dpkg-buildpackage -us -uc --host-arch arm64

	popd
done
