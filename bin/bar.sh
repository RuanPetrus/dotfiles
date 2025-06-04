#!/bin/sh

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
THEMESPATH="$SCRIPTPATH/bar_themes"
# . "$THEMESPATH/gruvchad.sh"
. "$THEMESPATH/xresources.sh"

split() {
	# For ommiting the . without calling and external program.
	IFS=$2
	set -- $1
	printf '%s' "$@"
}

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$black^ ^b$grey^ $cpu_val"
}

battery() {
	for battery in /sys/class/power_supply/BAT?*; do
		# If non-first battery, print a space separator.
		[ -n "${capacity+x}" ] && printf " "
		# Sets up the status and capacity
		case "$(cat "$battery/status" 2>&1)" in
			"Full") status="⚡" ;;
			"Discharging") status="🔋" ;;
			"Charging") status="🔌" ;;
			"Not charging") status="⚡" ;;
			"Unknown") status="♻️" ;;
			*) exit 1 ;;
		esac
		capacity="$(cat "$battery/capacity" 2>&1)"
		# Will make a warn variable if discharging and low
		[ "$status" = "🔋" ] && [ "$capacity" -le 25 ] && warn="❗"
		# Prints the info
		printf "^c$blue^ %s %s%d%%" "$status" "$warn" "$capacity"; unset warn
	done
}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$blue^^b$black^ "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	# Wifi
	if [ "$(cat /sys/class/net/w*/operstate 2>/dev/null)" = 'up' ] ; then
		wifiicon="󰖩"
	elif [ "$(cat /sys/class/net/w*/operstate 2>/dev/null)" = 'down' ] ; then
		[ "$(cat /sys/class/net/w*/flags 2>/dev/null)" = '0x1003' ] && wifiicon="󰤭" || wifiicon="󱛅"
	fi
	# Ethernet
	[ "$(cat /sys/class/net/e*/operstate 2>/dev/null)" = 'up' ] && ethericon="󱎔" || ethericon="❎"
	[ "$(cat /sys/class/net/e*/operstate 2>/dev/null)" = 'up' ] && neticon=$ethericon|| neticon=$wifiicon

	if [ "$(cat /sys/class/net/w*/operstate 2>/dev/null)" = 'up' ] ; then
		netstatus="Connected"
	elif [ "$(cat /sys/class/net/w*/operstate 2>/dev/null)" = 'down' ] ; then
		netstatus="Disconnected"
	fi

	[ "$(cat /sys/class/net/e*/operstate 2>/dev/null)" = 'up' ] && netstatus="Connected"

	printf "^c$black^^b$blue^ %s ^c$blue^^b$black^ %s" "$neticon" "$netstatus"
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆  "
	printf "^c$black^^b$blue^ $(date '+%H:%M')  "
}

day() {
  printf "^c$blue^^b$black^ $(date +'%d/%m/%Y')"
}


volume() {
	vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
	# If muted, print 🔇 and exit.
	[ "$vol" != "${vol%\[MUTED\]}" ] && printf "^c$red^ 🔇" && return

	vol="${vol#Volume: }"
	vol="$(printf "%.0f" "$(split "$vol" ".")")"

	case 1 in
		$((vol >= 70)) ) icon="" ;;
		$((vol >= 30)) ) icon="" ;;
		$((vol >= 1)) ) icon="" ;;
		* ) printf "^c$red^ 󰖁" && return ;;
	esac

	printf "^c$red^ $icon $vol%%"
}

# echo "$(battery) $(volume) $(cpu) $(mem) $(wlan) $(clock) $(day)"
while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ]
  interval=$((interval + 1))

  # echo "$(battery) $(cpu) $(mem) $(wlan) $(clock) $(day)"
  sleep 1 && xsetroot -name "$(battery) $(volume) $(cpu) $(mem) $(wlan) $(clock) $(day)"
done
