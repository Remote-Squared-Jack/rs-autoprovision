#!/bin/bash

# <----------------------------------------- Generate Serial Number ----------------------------------------->

FILE=/home/pi/serial
if [[ -f "$FILE" ]]; then
    echo "$FILE exists."
else
    echo Reached target: 'Get MAC address'
    IFACE=wlan0
    read MAC </sys/class/net/$IFACE/address
    echo $MAC

    echo Reached target: 'Grab last 4 from MAC and remove the ":"'
    lastMAC=$(echo $MAC | awk '{print substr( $0, 13 ) }')
    echo $lastMAC
    echo 'Removing ":"'
    lastMAC=$(echo $lastMAC | sed 's/://g')
    echo 'Result:'
    echo $lastMAC

    echo Reached target: 'Get time in ms'
    time=$(($(date +%s%N)/1000))

    echo Reached target: 'Combine lastMAC and time for serial'
    serial=$lastMAC-$time
    echo $serial >> /home/pi/serial.var

# <----------------------------------------- Set Hostname ----------------------------------------->

    echo Reached target: 'Saves the serial num to hostname file to be set on reboot'
    echo r2d$serial > /etc/hostname

# <----------------------------------------- URL Bits ----------------------------------------->

    echo Reached target: 'Detect, read, and collect the data from /boot/URL'

    URL=$(cat /boot/url) # Boot url

    sudo echo $'chromium-browser --disable-infobars --noerrdialogs --incognito --check-for-update-interval=1 --simulate-critical-update --kiosk \'' + $URL + ''\'' >> /etc/xdg/openbox/autostart

    echo Reached target: 'Auto refresh'
    sudo echo 'export display=:0,0' >> /home/pi/keyF5
    sudo echo 'xdotool keydown F5; xdotool keyup F5 &' >> /home/pi/keyF5
#'
    sudo echo 'exit' >> /home/pi/keyF5
    sudo chmod +x /home/pi/keyF5
    sudo chown pi:pi /home/pi/keyF5
    sudo -u pi (crontab -l > autoRefresh; echo "0 */120 * * * /home/pi/keyF5") | crontab -
    #sudo -u pi crontab -l > autoRefresh
    #sudo -u pi echo "0 */30 * * * /home/pi/keyF5" >> autoRefresh # Refresh every 30 min
    #sudo -u pi crontab autoRefresh
    rm autoRefresh
fi

# <----------------------------------------- EOF ----------------------------------------->
echo Reached target: 'EOF'
