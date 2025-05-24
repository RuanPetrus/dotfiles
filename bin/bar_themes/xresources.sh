query_xresources() {
	query=$1
	while IFS=: read -r prop value; do
    	[[ $query == $prop ]] && echo $value
	done < <(xrdb -q)
}
black=$(query_xresources "*color0")
green=$(query_xresources "*color2")
white=$(query_xresources "*color9")
grey=$(query_xresources "*color12")
blue=$(query_xresources "*color3")
red=$(query_xresources "*color14")
darkblue=$(query_xresources "*color8")
