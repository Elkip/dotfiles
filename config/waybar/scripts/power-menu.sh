#!/bin/sh

DIALOG=Xdialog

$DIALOG --allow-close\
    --stdout\
    --title 'Exit'\
    --menu 'Choose action..'\
           14 50 10 \
    'Lock' "" \
    'Shutdown' "" \
    'Reboot' "" \
    1> /tmp/exitval.$$ 2> /dev/null

ACTION=`cat /tmp/exitval.$$`
rm -f /tmp/exitval.$$

case $ACTION in
    'Lock') swaylock -f ;;
    'Shutdown') shutdown now;;
    'Reboot') reboot ;;
    *) exit ;;
esac
