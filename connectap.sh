# This script sets up and starts a Wi-Fi Access Point (AP) on a Samsung NX300 camera.
# It performs the following steps:
# 1. Waits for 5 seconds to ensure the system is ready.
# 2. Copies the hostapd and DHCP configuration files from the camera's storage to a temporary directory.
# 3. Starts the Wi-Fi AP using the `wlan.sh` script and logs output to a file.
# 4. Starts the DHCP server with a specified IP address and logs output to the same file.
# 5. Waits for another 5 seconds to allow the camera's AP to initialize.
# 6. Reads the SSID and password from the hostapd configuration file, if available.
#    - If no password is set, it defaults to "(kein Passwort)" (no password).
#    - If the configuration file is missing, it sets the SSID to "(unbekannt)" (unknown).
# 7. Displays an informational window using `yad` with the AP details (SSID, password, and instructions).
# 8. Activates the camera's display by simulating a key press using `xdotool`.
#!/bin/sh
#
sleep 5
cp /mnt/mmc/hostapd.conf /tmp/
cp /mnt/mmc/dhcpd.conf /tmp/
/usr/bin/wlan.sh start_softap NL 0x8210 >> /mnt/mmc/wifi_ap.log 2>&1
/usr/bin/wlan.sh start_dhcpd 192.168.4.1 >> /mnt/mmc/wifi_ap.log 2>&1

# Wait for the camera to start up
sleep 5



# Info-Text für YAD-Fenster
text="\
-----------------------------
 NX -- AP
-----------------------------

Access Point gestartet!



Telnet/FTP auf Kamera aktiv.

Verbinde dich mit dem WLAN
und öffne http://192.168.4.1
im Browser.
"

# Hostapd-Konfiguration auslesen
CONF="/mnt/mmc/hostapd.conf"
if [ -f "$CONF" ]; then
    SSID=$(grep "^ssid=" "$CONF" | cut -d= -f2)
    PASS=$(grep "^wpa_passphrase=" "$CONF" | cut -d= -f2)
    [ -z "$PASS" ] && PASS="(kein Passwort)"
else
    SSID="(unbekannt)"
    PASS="(kein Passwort)"
fi

# Info-Text vorbereiten
text="\
-----------------------------
 NX Remote Controller - AP
-----------------------------

Access Point gestartet!

Netzwerkname (SSID):
  $SSID

Passwort:
  $PASS

Telnet/FTP auf Kamera aktiv.
"


# Fenster anzeigen
chroot /mnt/mmc/remote/tools yad \
    --center --no-focus --timeout=15 --timeout-indicator=bottom \
    --text="$text" &

# Startmenü kurz aktivieren, um Display zu wecken
sleep 2
chroot /mnt/mmc/remote/tools xdotool key Super_L