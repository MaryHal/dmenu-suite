#!/bin/sh

MENU_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $MENU_DIR/scripts/lib/menu_helpers.sh

$MENU_DIR/scripts/$@
