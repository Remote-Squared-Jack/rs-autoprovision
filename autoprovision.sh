#!/bin/bash

# <----------------------------------------- Dakboard Requirements ----------------------------------------->

sudo apt-get -y update

# Xorg requirements
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y

# Chromium browser install
sudo apt-get install --no-install-recommends chromium-browser -y

# Refresh tool
sudo apt-get install xdotool -y

# <----------------------------------------- Openbox Config ----------------------------------------->

# Remove splash
sudo echo 'disable_splash=1' >> /boot/config.txt

# Remove screensaver
sudo echo '# Disable screen saver / screen blanking / power management' >> /etc/xdg/openbox/autostart
sudo echo 'xset s off' >> /etc/xdg/openbox/autostart
sudo echo 'xset s noblank' >> /etc/xdg/openbox/autostart
sudo echo 'xset -dpms' >> /etc/xdg/openbox/autostart

# Allow quitting the X server with CTRL-ATL-Backspace for debuging
sudo echo 'setxkbmap -option terminate:ctrl_alt_bksp' >> /etc/xdg/openbox/autostart


# Start Chromium in kiosk mode
sudo echo 'sed -i \'s/\"exited_cleanly\":false/\"exited_cleanly\":true/\' ~/.config/chromium/\'Local State\'' >> /etc/xdg/openbox/autostart
sudo echo 'sed -i \'s/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/\' 	~/.config/chromium/Default/Preferences' >> /etc/xdg/openbox/autostart
#sudo echo chromium-browser --disable-infobars --noerrdialogs --incognito --check-for-update-interval=1 --simulate-critical-update --kiosk '[https://DAKBOARD-CUSTOM-URL-HERE]'

# Start at boot (xserver)
sudo echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]																		 && startx -- -nocursor' >> /home/pi/.profile

# Vertical screen
#sudo echo 'display_rotate=1' >> /boot/config.txt

echo Reached target: 'Auto refresh'
sudo echo 'export display=:0,0' >> /home/pi/keyF5
sudo echo 'xdotool keydown F5; xdotool keyup F5 &' >> /home/pi/keyF5
    #'
sudo echo 'exit' >> /home/pi/keyF5
sudo chmod +x /home/pi/keyF5
sudo chown pi:pi /home/pi/keyF5
sudo -u pi crontab -l > autoRefresh; echo "0 */120 * * * /home/pi/keyF5" | crontab -
rm autoRefresh

# <----------------------------------------- EOF and reboot ----------------------------------------->
sudo reboot
