#!/bin/bash

MenuProg=""
BACKEND=${1:-dmenu}

case "$BACKEND" in
    'fzf')
        MenuProg="fzf -x"
        ;;
    'dmenu')
        # Dmenu 2: Open on laptop monitor.
        source $HOME/bin/menu/lib/dmenurc
        MenuProg="$DMENU -s 0"
        ;;
    'rofi')
        MenuProg="rofi -dmenu"
        ;;
esac

###################
## Functions
###################

function getPromptOption ()
{
    case "$BACKEND" in
        'fzf')
            promptOption="--prompt"
            ;;
        'dmenu')
            promptOption="-p"
            ;;
        'rofi')
            promptOption="-p"
            ;;
    esac

    echo "$promptOption"
}

# Feeding menu items and a prompt to Dmenu the regular way gets messy.
# To save sanity, this function makes it as simple as:
#   menu "Your Prompt" "Item A" ["Item B" "Item C" ...]
function menu ()
{
    # We grab the prompt message...
    local prompt="$1"
    shift

    local items=""
    # We will now iterate through the rest of the arguments...
    until [[ -z "$1" ]]; do
        # ...add the menu item to the list we're going to feed to Dmenu...
        items="$items$1"
        # ...move on to the next argument...
        shift
        # ...and keep doing this until there are no more arguments.
    done

    # Prompt "Adapter" for our menuing backend
    promptOption=$(getPromptOption "$prompt")

    # Now that we're done with that, we can feed the hungry Dmenu.
    # We feed the list though `head -c-1` first, to get rid of that
    # trailing newline, since Dmenu isn't smart enough to ignore it.
    echo "$items" | head -c-1 | $MenuProg $promptOption "$prompt"
}

# We can use menu() function for yes/no prompts.
function confirm ()
{
    menu "$*" 'No' 'Yes'
}

# And we can even use it for a simple notice.
function alert ()
{
    menu "$*" 'OK'
}
