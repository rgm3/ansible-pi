# vcgencmd(1) completion                                   -*- shell-script -*-

_vcgencmd_commands()
{
    local commands fallback re
    commands="$(/usr/bin/vcgencmd commands 2> /dev/null)"
    fallback="codec_enabled commands display_power get_camera get_config
        get_lcd_info get_mem get_throttled measure_temp measure_volts
        mem_oom version"
    re='commands="(.*)"'

    if [[ $commands =~ $re ]]; then
        commands="${BASH_REMATCH[1]}"
        commands="${commands//,}"
    else
        commands="${fallback}"
    fi

    compgen -W "$commands" -- "$cur"
}

_vcgencmd() {
    local cur prev cword opts='' args
    _init_completion -n ':' || return
    _count_args ':'

    if [[ $cword -eq 1 && $cur == -* ]] ; then
        mapfile -t COMPREPLY < <( compgen -W '-t -h --help' -- "$cur" )
        return 0
    fi

    if [[ $args -eq 1 ]]; then
        case "$prev" in
            -h|--help)
                ;;
            *)
                mapfile -t COMPREPLY < <( _vcgencmd_commands )
                ;;
        esac
        return 0
    fi

    if [[ $args -eq 2 ]]; then
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

    if [[ $args -eq 3 ]]; then
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
    [[ $prev == "get_config" ]] && __ltrim_colon_completions "$cur"

    return 0
} &&
complete -F _vcgencmd vcgencmd

# ex: filetype=sh
