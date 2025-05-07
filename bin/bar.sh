#!/bin/sh

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
THEMESPATH="$SCRIPTPATH/bar_themes"
. "$THEMESPATH/gruvchad.sh"

split() {
	# For ommiting the . without calling and external program.
	IFS=$2
	set -- $1
	printf '%s' "$@"
}

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$white^ ^b$grey^ $cpu_val"
}

apt_pkg_updates() {
  #updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
  # updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
  updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates"" updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
  printf "^c$blue^   $get_capacity"
}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨  ^d^%s" "^c$blue^ Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭  ^d^%s " " ^c$blue^ Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆  "
	printf "^c$black^^b$blue^ $(date '+%H:%M')  "
}

day() {
  printf "^c$blue^^b$black^ $(date +'%d/%m/%Y')"
}


# volume() {
# 	vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
# # If muted, print 🔇 and exit.
# 	[ "$vol" != "${vol%\[MUTED\]}" ] && printf "^c$red 🔇" && return
# 
# 	vol="${vol#Volume: }"
# 	vol="$(printf "%.0f" "$(split "$vol" ".")")"
# 
# 	case 1 in
# 		$((vol >= 70)) ) icon="🔊" ;;
# 		$((vol >= 30)) ) icon="🔉" ;;
# 		$((vol >= 1)) ) icon="🔈" ;;
# 		* ) printf "^c$red 🔇" && return ;;
# 	esac
# 
# 	printf "^c$red $icon$vol%%"
# }

volume() {
	volumeval=$(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')
	printf "^c$red^ 🔊 $volumeval%"
	return
}

# echo "$(battery) $(volume) $(cpu) $(mem) $(wlan) $(clock) $(day)"
while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ]
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$(battery) $(volume) $(cpu) $(mem) $(wlan) $(clock) $(day)"
done
