# vcgencmd(1) completion                                   -*- shell-script -*-

_vcgencmd_commands()
{
    local commands
    eval "$(/usr/bin/vcgencmd commands | tr -d ',')"
    [[ ${commands} ]] || commands="commands display_power get_config
        get_lcd_info get_throttled get_mem measure_temp measure_volts
        mem_oom version"
    compgen -W "${commands}" -- "$cur"
}

_vcgencmd() {
    local cur prev options
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $COMP_CWORD -eq 1 ]] ; then
        if [[ $cur == -* ]]; then
            COMPREPLY=( $( compgen -W '-t -h --help' -- "$cur" ) )
        else
            COMPREPLY=( $(_vcgencmd_commands) )
        fi
        return 0
    fi

    case "${prev}" in
        -h|--help)
            return 0
            ;;
        -t)
            COMPREPLY=( $(_vcgencmd_commands) )
            return 0
            ;;
    esac

    case "${prev}" in
        codec_enabled)
            options='AGIF FLAC H263 H264 MJPA MJPB MJPG MPG2 MPG4 MVC0 PCM
                THRA VORB VP6 VP8 WMV9 WVC1'
            ;;
        measure_clock)
            options='arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi'
            ;;
        measure_volts)
            options='core sdram_c sdram_i sdram_p'
            ;;
        get_mem)
            options='arm gpu'
            ;;
        get_config)
            options='int str'
            options+=" $("$1" get_config str | command sed -e 's/=.*$//')"
            options+=" $("$1" get_config int | command sed -e 's/=.*$//')"
            ;;
        vcos)
            options='version log'
            ;;
        log)
            options='status'
            ;;
    esac
    COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
    return 0
} &&
complete -F _vcgencmd vcgencmd

# ex: filetype=sh
