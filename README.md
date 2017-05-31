Raspberry Pi Basic Setup Playbook
=================================

A playbook to minimally configure a stock Raspbian Jessie Lite system.

This includes:

* Essential packages such as vim and git
* US locale and keyboard setup
* Timezone configuration
* Python hacking packages
* Some light dotfile config

Prepare SD card - Headless setup
================================

When you can't find your mini HDMI adapter and don't want to drag out your
USB-Serial console cable then specify network settings directly in the /boot
partition of the SD card.

```bash
# change to suit your environment
BOOTDIR="/mnt/sdcard/boot"
WIFI_SSID="EXAMPLE-NET"
WIFI_PASS="EXAMPLE-PASS"

# Enable SSH on first boot.  Your pi may become part of an IoT botnet.
touch "${BOOTDIR}"/ssh

# Supply bootstrap wifi information
# Use wpa_passphrase to generate an encrypted psk, or stick with cleartext
cat <<EOF > "${BOOTDIR}"/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="${WIFI_SSID}"
    psk="${WIFI_PASS}"
}
EOF
```
