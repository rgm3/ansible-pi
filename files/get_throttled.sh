#!/bin/bash

# Human-readable vcgencmd get_throttled
# rgm 2021-07-09
#
# https://www.raspberrypi.org/forums/viewtopic.php?t=251032
# https://www.raspberrypi.org/documentation/raspbian/applications/vcgencmd.md

# Under-voltage usually indicates inadequate power supply.

set -euo pipefail
IFS=$'\n\t'

readonly ISSUES_MAP=( \
  [0x00001]="Under-voltage detected (check power supply)" \
  [0x00002]="Arm frequency capped (> 60 °C)" \
  [0x00004]="Currently throttled (> 80 °C)"
  [0x00008]="Soft temperature limit active" \
  [0x10000]="Under-voltage has occurred" \
  [0x20000]="Arm frequency capping has occurred" \
  [0x40000]="Throttling has occurred" \
  [0x80000]="Soft temperature limit has occurred" \
)

# cpu clock: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
readonly INFO_MAP=( \
  [0x00001]="/usr/bin/vcgencmd measure_volts" \
  [0x00002]="/usr/bin/vcgencmd measure_clock arm" \
  [0x00004]="/usr/bin/vcgencmd measure_temp" \
  [0x00008]="/usr/bin/vcgencmd measure_temp" \
)

function main {
  local get_throttled flags rc
  get_throttled=$(vcgencmd get_throttled)
  flags="$(( ${get_throttled##*=} ))"
  rc=0

  if (( flags & 0xF000F )); then
    printf 'vcgencmd get_throttled: %s\n' "${get_throttled}"
  fi

  if (( flags & 0xF )); then
    echo "Current issues:"
    for i in 0 1 2 3; do
      idx=$(( 1 << i ))
      (( flags & idx )) && \
        printf '\t    0x%x - %s (%s)\n' $idx "${ISSUES_MAP[idx]}" "$(eval "${INFO_MAP[idx]}")"
    done
    echo
    rc=1
  fi

  if (( flags & 0xF0000 )); then
    echo "Previous issues:"
    for i in 0 1 2 3; do
      idx=$(( 1 << (16 + i) ))
      (( flags & idx )) && \
        printf '\t0x%x - %s\n' $idx "${ISSUES_MAP[idx]}"
    done
    echo
    rc=2
  fi

  return $rc
}

main
