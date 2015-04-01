Menu Suite
==========

This is a collection of shell scripts that interface with either [dmenu](http://tools.suckless.org/dmenu/) or [fzf](https://github.com/junegunn/fzf).

Everyone's *nix setups are different. As such, these scripts fit my personal use case; it's not guaranteed that it will fit yours.

Included Scripts
================

brightnessmenu -> set laptop monitor brightness with xbacklight.
cpumenu -> query and set system's enabled cpu profiles.
dvdmenu -> navigate dvd with mpv.
infomenu -> display some system information with acpi.
killmenu -> kill processes.
menumenu -> menu to select these menus.
monitormenu -> setup (preconfigured, hardcoded) monitor layouts with xrandr.
mpcmenu -> interface for [mpd](http://www.musicpd.org/) (using [mpc](http://linux.die.net/man/1/mpc)).
netmenu -> wifi profile select using netctl.
runmenu -> list and run programs in user's $PATH.
shutdownmenu -> shutdown, reboot, and sleep.
wallpapermenu -> select a wallpaper from a hardcoded directory. Need to implement selecting specific wallpapers for specific monitors.
wmmenu -> unfinished script to interact with wmctrl.

Possible Usage
==============

All scripts take a single optional argument (1 or 0) to decide whether to use fzf or not. If this argument is excluded, dmenu is used by default.

Run mpcmenu (interface for mpd client) with dmenu inside current terminal:

    ~/bin/menu/scripts/mpcmenu 0

Run mpcmenu in a new terminal emulator (urxvt) window with fzf:

    urxvt -name "fzf-menu" -geometry 80x24 -e ~/bin/menu/scripts/mpcmenu 1

We set an interface name for our urxvt window so we can allow a window manager to specifically manage these menus. For example, [bspwm](https://github.com/baskerville/bspwm) allows us to set rules for window interfaces:

    bspc rule -a fzf-menu floating=on,center=on,monitor=LVDS1,follow=on

With this, our fzf-enabled menus will be floating and centered on my laptop monitor. It will also focus itself if I run it from any other monitor.
