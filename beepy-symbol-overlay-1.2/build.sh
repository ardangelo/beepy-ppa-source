#!/bin/bash

CXX=arm-linux-gnueabihf-g++ \
OBJCOPY=arm-linux-gnueabihf-objcopy \
	dpkg-buildpackage -us -uc --host-arch armhf
