#!/usr/bin/env bats
# Test suite for vcgencmd command completion
load /usr/share/bash-completion/bash_completion || true
load /usr/share/bash-completion/completions/vcgencmd

#DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

complete_command() {
  local cmd="$*"

  COMP_LINE="${cmd}"
  mapfile -t COMP_WORDS < <( compgen -W "${cmd}" )

  # index of current word in $COMP_WORDS array
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
  if [[ ${cmd: -1} == " " ]]; then
    COMP_CWORD=$(( COMP_CWORD + 1 ))
  fi

  # current pointer position in line
  COMP_POINT="${#cmd}"

  #echo >&3
  #echo "COMP_LINE=${COMP_LINE}\$" >&3
  #echo "COMP_WORDS=${COMP_WORDS[@]} length ${#COMP_WORDS[@]}" >&3
  #echo "COMP_CWORD=${COMP_CWORD}" >&3
  #echo "COMP_POINT=${COMP_POINT}" >&3

  # name of completion function
  complete_func=$(complete -p "${COMP_WORDS[0]}" | sed 's/.*-F \([^ ]*\) .*/\1/')
  [[ -n $complete_func ]]

  # Set the COMPREPLY array
  $complete_func "${COMP_WORDS[0]}" || true

  #echo "reply num=${#COMPREPLY[@]}" >&3
  #echo "opts=${COMPREPLY[@]}" >&3
}

@test "vcgencmd - -> -t -h --help" {
  complete_command "vcgencmd -"
  [[ "${COMPREPLY[*]}" == "-t -h --help" ]]
}

@test "--h -> --help" {
  complete_command "vcgencmd --h"
  [[ "${COMPREPLY[*]}" == "--help" ]]
}

@test "--help -> (nothing)" {
  complete_command "vcgencmd --help "
  [[ "${#COMPREPLY[@]}" -eq 0 ]]
}

@test "vcgencmd -xxx -> (nothing)" {
  complete_command "vcgencmd -xxx "
  [[ "${#COMPREPLY[@]}" -eq 0 ]]
}

@test "vcgencmd foobar -> (nothing)" {
  complete_command "vcgencmd foobar "
  [[ "${#COMPREPLY[@]}" -eq 0 ]]
}

@test "vcgencmd -> commands version get_config measure_temp ..." {
  complete_command "vcgencmd "
  [[ "${#COMPREPLY[@]}" -gt 60 ]]
  echo "${COMPREPLY[*]}" | grep -Ewo "(commands|version|get_config|measure_temp)"
}

@test "vcgencmd -t -> commands version get_config measure_temp ..." {
  complete_command "vcgencmd -t "
  [[ "${#COMPREPLY[@]}" -gt 60 ]]
  echo "${COMPREPLY[*]}" | grep -Ewo "(commands|version|get_config|measure_temp)"
}

@test "codec_enabled -> FLAC MJPG ..." {
  complete_command "vcgencmd codec_enabled "
  echo "${COMPREPLY[*]}" | grep -Ewo "(FLAC|MJPG|H263|PCM|VORB)"
}

@test "measure_clock -> arm core uart ..." {
  complete_command "vcgencmd measure_clock "
  echo "${COMPREPLY[*]}" | grep -Ewo "(arm|core|uart|hdmi)"
}

@test "measure_volts -> core sdram_[cip]" {
  complete_command "vcgencmd measure_clock "
  echo "${COMPREPLY[*]}" | grep -Ewo "(core|sdram_[cip])"
}

@test "get_mem -> arm gpu" {
  complete_command "vcgencmd get_mem "
  echo "${COMPREPLY[*]}" | grep -Ewo "(arm|gpu)"
}

@test "get_config -> int str arm_freq ..." {
  complete_command "vcgencmd get_config "
  [[ "${#COMPREPLY[@]}" -gt 30 ]]
  echo "${COMPREPLY[*]}" | grep -Ewo "(int|str|device_tree|arm_freq|total_mem|hdmi_cvt:0|enable_tvout)"
}

@test "get_config hdmi_cvt: -> 0 1" {
  complete_command "vcgencmd get_config hdmi_cvt:"
  [[ "${COMPREPLY[*]}" == "0 1" ]]
}

@test "get_config hdmi_pixel_freq_li -> hdmi_pixel_freq_limit:0" {
  complete_command "vcgencmd get_config hdmi_pixel_freq_li"
  [[ "${COMPREPLY[*]}" == "hdmi_pixel_freq_limit:0" ]]
}

@test "vcos -> version log" {
  complete_command "vcgencmd vcos "
  echo "${COMPREPLY[*]}" | grep -Ewo "(version|log)"
}

@test "display_power -> 0 1 -1" {
  complete_command "vcgencmd display_power "
  [[ "${COMPREPLY[*]}" == "0 1 -1" ]]
}

@test "-t display_power -> 0 1 -1" {
  complete_command "vcgencmd -t display_power "
  [[ "${COMPREPLY[*]}" == "0 1 -1" ]]
}

@test "display_power [0, 1] -> 0 1 2 3 7" {
  local display_nums="0 1 2 3 7"
  complete_command "vcgencmd display_power 0 "
  [[ "${COMPREPLY[*]}" == "$display_nums" ]]
  complete_command "vcgencmd display_power 1 "
  [[ "${COMPREPLY[*]}" == "$display_nums" ]]
}

@test "display_power -1 -> 0 1 2 3 7" {
  local display_nums="0 1 2 3 7"
  complete_command "vcgencmd display_power -1 "
  [[ "${COMPREPLY[*]}" == "$display_nums" ]]
}

@test "BADARG display_power -1 -> (nothing)" {
  complete_command "vcgencmd BADARG display_power -1 "
  echo "${COMPREPLY[*]}"
  [[ "${COMPREPLY[*]}" == "" ]]
}

@test "display_power BADARG -1 -> (nothing)" {
  complete_command "vcgencmd display_power BADARG -1 "
  echo "${COMPREPLY[*]}"
  [[ "${COMPREPLY[*]}" == "" ]]
}

@test "-t display_power -1 -> 0 1 2 3 7" {
  complete_command "vcgencmd -t display_power -1 "
  [[ "${COMPREPLY[*]}" == "0 1 2 3 7" ]]
}

@test "vcos log -> status" {
  complete_command "vcgencmd vcos log "
  [[ "${COMPREPLY[*]}" == "status" ]]
}

@test "-t vcos log -> status" {
  complete_command "vcgencmd -t vcos log "
  [[ "${COMPREPLY[*]}" == "status" ]]
}
