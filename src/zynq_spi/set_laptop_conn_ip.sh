#!/bin/sh

# Configures eth0 to sabe subnet as laptop (mr99).
# Only use this script when zynq and mr99 are directly connected
# via an ethernet cable (and not via a router or switch).
# Also note that this config is lost on reboot (we don't want
# to make this the default, as it's limiting)

ifconfig eth0 192.168.0.2 netmask 255.255.255.0
