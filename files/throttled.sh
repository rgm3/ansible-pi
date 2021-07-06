#!/bin/bash
# https://www.raspberrypi.org/forums/viewtopic.php?t=251032
# https://www.raspberrypi.org/documentation/raspbian/applications/vcgencmd.md

# under voltage usually indicates inadequate power supply

STATUS=$(vcgencmd get_throttled | sed -n 's|^throttled=\(.*\)|\1|p')

if [[ ${STATUS} -ne 0 ]]; then
  if [ $((STATUS & 0x00001)) -ne 0 ]; then
    echo "Under-voltage detected currently"
  elif [ $((STATUS & 0x10000)) -ne 0 ]; then
    echo "Under-voltage has occurred"
  fi

  if [ $((STATUS & 0x00002)) -ne 0 ]; then
    echo "Arm frequency currently capped"
  elif [ $((STATUS & 0x20000)) -ne 0 ]; then
    echo "Arm frequency capping has occurred"
  fi

  if [ $((STATUS & 0x00004)) -ne 0 ]; then
    echo "CPU is currently throttled"
  elif [ $((STATUS & 0x40000)) -ne 0 ]; then
    echo "CPU has previously been throttled"
  fi

  if [ $((STATUS & 0x00008)) -ne 0 ]; then
    echo "Soft temperature limit active"
  elif [ $((STATUS & 0x80000)) -ne 0 ]; then
    echo "Soft temperature limit has occurred"
  fi
fi
