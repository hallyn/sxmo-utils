#!/usr/bin/env sh

applyptrmatrix() {
	PTRID="$(  
		xinput | grep -iE 'touchscreen.+pointer' | grep -oE 'id=[0-9]+' | cut -d= -f2
	)"
	xinput set-prop "$PTRID" --type=float --type=float "Coordinate Transformation Matrix" "$@"
}

isrotated() {
	xrandr | grep primary | cut -d' ' -f 5 | grep right && return 0
	return 1
}

rotnormal() {
	xrandr -o normal
	applyptrmatrix 0 0 0 0 0 0 0 0 0
	pkill lisgd
	sxmo_lisgdstart.sh -o 0 &
	exit 0
}

rotright() {
	xrandr -o right
	applyptrmatrix 0 1 0 -1 0 1 0 0 1
	pkill lisgd
	sxmo_lisgdstart.sh -o 1 &
	exit 0
}

rotleft() {
	xrandr -o left
	applyptrmatrix 0 -1 1 1 0 0 0 0 1
	pkill lisgd
	sxmo_lisgdstart.sh -o -1 &
	exit 0
}


rotate() {
	if isrotated; then rotnormal; else rotright; fi
}

"$1"
