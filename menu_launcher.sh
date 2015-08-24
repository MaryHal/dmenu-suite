#!/bin/sh

MENU_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

flock -n /tmp/menusuite.lock -c "${MENU_DIR}/scripts/$*"
