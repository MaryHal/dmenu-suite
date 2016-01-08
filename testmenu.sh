#!/bin/sh

MENU_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $MENU_DIR/scripts/lib/menu_helpers.sh

items=$'asdf\nzxcv\nqwer'

value=$(menu "Hello World" "$items")
# value=$($MenuProg $promptOption "Hello World" <<< "$items")
confirm "$value z" "b"

