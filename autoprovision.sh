#!/bin/bash

# <----------------------------------------- Generate Serial Number ----------------------------------------->

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
serial='$lastMAC-$time'
echo $serial > /home/pi/serial.var

# <----------------------------------------- Set Hostname ----------------------------------------->

echo Reached target: 'Saves the serial num to hostname file to be set on reboot'
echo 'r2d$serial' > /etc/hostname

# <----------------------------------------- Dakboard Requirements ----------------------------------------->

echo Reached target: 'Xorg requirements'
sudo apt-get -y install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox

echo Reached target: 'Chromium browser install'
sudo apt-get -y install --no-install-recommends chromium-browser

echo Reached target: 'Refresh tool'
sudo apt-get -y install xdotool

# <----------------------------------------- Openbox Config ----------------------------------------->

echo Reached target: 'Remove splash'
echo 'disable_splash=1' >> /boot/config.txt

echo Reached target: 'Remove screensaver'
sudo echo '# Disable screen saver / screen blanking / power management' >> /etc/xdg/openbox/autostart
sudo echo 'xset s off' >> /etc/xdg/openbox/autostart
sudo echo 'xset s noblank' >> /etc/xdg/openbox/autostart
sudo echo 'xset -dpms' >> /etc/xdg/openbox/autostart

echo Reached target: 'Allow quitting the X server with CTRL-ATL-Backspace for debuging'
setxkbmap -option terminate:ctrl_alt_bksp


echo Reached target: 'Start Chromium in kiosk mode'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' 	~/.config/chromium/Default/Preferences
chromium-browser --disable-infobars --noerrdialogs --incognito --check-for-update-interval=1 --simulate-critical-update --kiosk '[https://DAKBOARD-CUSTOM-URL-HERE]'

echo Reached target: 'Start at boot (xserver)'
sudo echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]																		 && startx -- -nocursor' >> /home/pi/.profile

echo Reached target: 'Vertical screen'
sudo echo 'display_rotate=1' >> /boot/config.txt

echo Reached target: 'Auto refresh'
sudo echo 'export display=:0,0' >> /home/pi/keyF5
sudo echo 'xdotool keydown F5; xdotool keyup F5 &' >> /home/pi/keyF5
sudo echo 'exit' >> /home/pi/keyF5
sudo chmod +x /home/pi/keyF5
sudo chown pi:pi /home/pi/keyF5
crontab -l > autoRefresh
echo "0 */30 * * * /home/pi/keyF5" >> autoRefresh # Refresh every 30 min
crontab autoRefresh
rm autoRefresh

# <----------------------------------------- EOF and reboot ----------------------------------------->
echo Reached target: 'Reboot'
sudo reboot
