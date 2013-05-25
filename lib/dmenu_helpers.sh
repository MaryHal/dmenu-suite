#!/bin/bash

# We're gonna guard against multiple instances of dmenu
#PIPE="/tmp/dmenupipe"

#if [ "$(ps --no-headers -C X)" ]; then
#    if [ -f $HOME/.dmenurc ]; then
#        . $HOME/.dmenurc
#    else
#        DMENU="dmenu -i"
#    fi
#else
#    DMENU="slmenu -i"
#fi
source $HOME/bin/menu/lib/dmenurc

###################
## Functions
###################

# Feeding menu items and a prompt to Dmenu the regular way gets messy.
# To save sanity, this function makes it as simple as:
#   menu "Your Prompt" "Item A" ["Item B" "Item C" ...]
menu ()
{
    # We grab the prompt message...
    prompt="$1"
    # ...then shift to the next argument.
    shift
    # We will now iterate through the rest of the arguments...
    until [ -z "$1" ]; do
        # ...add the menu item to the list we're going to feed to Dmenu...
        items="$items$1"
        # ...move on to the next argument...
        shift
        # ...and keep doing this until there are no more arguments.
    done
    # Now that we're done with that, we can feed the hungry Dmenu.
    # We feed the list though `head -c-1` first, to get rid of that
    # trailing newline, since Dmenu isn't smart enough to ignore it.
    #echo "$items" | head -c-1 | $DMENU -i -p "$prompt"
    echo "$items" | head -c-1 | $DMENU -i -p "$prompt"
}

# We can use menu() function for yes/no prompts.
confirm ()
{
    menu "$*" 'No' 'Yes'
}

# And we can even use it for a simple notice.
alert ()
{
    menu "$*" 'OK'
}

