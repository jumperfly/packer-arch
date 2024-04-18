#!/usr/bin/env bash

set -e

# Clean
rm -f /var/cache/pacman/pkg/*
rm -f /var/lib/pacman/sync/*
rm -f /etc/machine-id

# Optimise disk
dd if=/dev/zero of=/ZERO bs=1M || echo "ignoring expected dd out of space error"
rm -f /ZERO
sync
