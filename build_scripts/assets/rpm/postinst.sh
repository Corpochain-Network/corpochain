#!/usr/bin/env bash
# Post install script for the UI .rpm to place symlinks in places to allow the CLI to work similarly in both versions

set -e

ln -s /opt/corpochain/resources/app.asar.unpacked/daemon/corpochain /usr/bin/corpochain || true
ln -s /opt/corpochain/corpochain /usr/bin/corpochain || true
