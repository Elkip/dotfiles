#!/bin/sh
# For this to work add a sudoers exception for /bin/systemctl restart sddm.service
DIALOG=Xdialog

$DIALOG --allow-close\
    --stdout\
    --title 'Exit'\
    --menu 'Choose action..'\
           14 50 10 \
    'Lock' "" \
    'Logout' "" \
    'Shutdown' "" \
    'Reboot' "" \
    1> /tmp/exitval.$$ 2> /dev/null

ACTION=`cat /tmp/exitval.$$`
rm -f /tmp/exitval.$$

case $ACTION in
    'Lock') swaylock -f ;;
    'Logout') sudo systemctl restart sddm.service ;;
    'Shutdown') shutdown now;;
    'Reboot') reboot ;;
    *) exit ;;
esac
