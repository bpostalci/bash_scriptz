#!/bin/bash

com=$(xrandr | grep -w connected | grep -w DP-1-1 | wc -l)

if [ $com > 0 ]; then
	$(xrandr --output DP-1-1 --scale 1.3x1.3 --pos 1950x185)
fi

exit 0
