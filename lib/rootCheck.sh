##
# Check if the current user is root.
#
rootCheck()
{
    if [[ $EUID -ne 0 ]]; then
        echo "${NAME:-$(basename $0)} must be run as root" >&2
        exit 1
    fi
}
