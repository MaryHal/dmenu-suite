#!/bin/bash

MenuProg=""

# Do not use fzf by default
USE_FZF=${1:-0}

if [[ $USE_FZF == 1 ]]; then
    MenuProg="fzf -x"
else
    # Common dmenu settings
    source $HOME/bin/menu/lib/dmenurc
    MenuProg="$DMENU -l 12"
fi

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
    shift

    items=""
    # We will now iterate through the rest of the arguments...
    until [ -z "$1" ]; do
        # ...add the menu item to the list we're going to feed to Dmenu...
        items="$items$1"
        # ...move on to the next argument...
        shift
        # ...and keep doing this until there are no more arguments.
    done

    # Prompt "Adapter" for dmenu/fzf
    MenuCmd="$MenuProg"
    if [[ -n "$prompt" ]]; then
        if [[ $USE_FZF == 1 ]]; then
            MenuCmd="$MenuCmd --prompt $prompt"
        else
            # Common dmenu settings
            source $HOME/bin/menu/lib/dmenurc
            MenuCmd="$MenuCmd -p $prompt"
        fi
    fi

    # Now that we're done with that, we can feed the hungry Dmenu.
    # We feed the list though `head -c-1` first, to get rid of that
    # trailing newline, since Dmenu isn't smart enough to ignore it.
    echo "$items" | head -c-1 | $MenuCmd
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
