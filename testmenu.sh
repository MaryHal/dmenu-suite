#!/bin/sh

source $HOME/bin/menu/lib/menu_helpers.sh

items=$'asdf\nzxcv\nqwer'

value=$(menu "Hello World" "$items")
# value=$($MenuProg $promptOption "Hello World" <<< "$items")
confirm "$value z" "b"
