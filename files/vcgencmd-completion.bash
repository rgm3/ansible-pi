# vcgencmd(1) completion                                   -*- shell-script -*-

_vcgencmd_commands()
{
    local commands fallback re
    fallback="codec_enabled commands display_power get_camera get_config
        get_lcd_info get_mem get_throttled measure_temp measure_volts
        mem_oom version"

    commands="$(/usr/bin/vcgencmd commands 2> /dev/null)"
    re='commands="(.*)"'
    if [[ $commands =~ $re ]]; then
        commands="${BASH_REMATCH[1]}"
        commands="${commands//,}"
    else
        commands="${fallback}"
    fi

    compgen -W "$commands" -- "$cur"
}

# True when first parameter is equal to the current word
# position, not counting leading optional arguments.
_vcgencmd_cword_ignore_optional_equals() {
   local num
   num="$1"

   if [[ ${COMP_WORDS[1]} == '-t' ]]; then
       (( num == COMP_CWORD - 1 ))
       return
   fi

   (( num == COMP_CWORD ))
}

_vcgencmd() {
    local cur prev cword opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cword="${COMP_CWORD}"
    opts=""

    if [[ $cword -eq 1 && $cur == -* ]] ; then
        mapfile -t COMPREPLY < <( compgen -W '-t -h --help' -- "$cur" )
        return 0
    fi

    if _vcgencmd_cword_ignore_optional_equals 1; then
        mapfile -t COMPREPLY < <( _vcgencmd_commands )
        return 0
    fi

    if _vcgencmd_cword_ignore_optional_equals 2; then
        case "$prev" in
            codec_enabled)
                opts='AGIF FLAC H263 H264 MJPA MJPB MJPG MPG2 MPG4 MVC0 PCM
                    THRA VORB VP6 VP8 WMV9 WVC1'
                ;;
            measure_clock)
                opts='arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi'
                ;;
            measure_volts)
                opts='core sdram_c sdram_i sdram_p'
                ;;
            get_mem)
                opts='arm gpu'
                ;;
            get_config)
                opts='int str'
                opts+=" $("$1" get_config str | command sed -e 's/=.*$//')"
                opts+=" $("$1" get_config int | command sed -e 's/=.*$//')"
                ;;
            vcos)
                opts='version log'
                ;;
            display_power)
                opts='0 1 -1'
                ;;
        esac
    fi

    if _vcgencmd_cword_ignore_optional_equals 3; then
        case "${COMP_WORDS[COMP_CWORD-2]}" in
            display_power)
                case "$prev" in
                    0|1|-1) opts='0 1 2 3 7' ;;
                esac
                ;;
            vcos)
                [[ $prev == "log" ]] && opts='status'
                ;;
        esac
    fi

    [[ -n $opts ]] && mapfile -t COMPREPLY < <( compgen -W "$opts" -- "$cur" )

    return 0
} &&
complete -F _vcgencmd vcgencmd

# ex: filetype=sh
