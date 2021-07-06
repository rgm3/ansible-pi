Raspberry Pi Basic Setup Playbook
=================================

A playbook to minimally configure a stock Raspberry Pi OS Lite system.

This includes:

* Essential packages such as vim and git
* US locale and keyboard setup
* Timezone configuration
* Python hacking packages
* Some light dotfile config

Prepare SD card - Headless setup
================================

When you can't find your mini HDMI adapter and don't want to drag out your
USB-Serial console cable, one can specify network settings directly in the
`/boot` partition of the SD card.

```bash
# This play enables ssh and adds wpa_supplicant.conf to a locally mounted
# /boot partition

# Typical GNU/Linux path
ansible-playbook -e boot_dir=/mnt/sdcard/boot boot-wifi-setup.yml

# Typical macOS path
ansible-playbook -e boot_dir=/Volumes/boot boot-wifi-setup.yml
```
