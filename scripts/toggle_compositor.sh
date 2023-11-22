#!/bin/bash
# Replace picom with your compositor of choice
# Useful for gaming as compositors hinder FPS

if [ $(ps -ax|grep picom|grep -v grep|wc -l) -gt '0' ]; then
	echo "killing picom"
	killall picom
else
	echo "launching picom"
	nohup picom >/dev/null 2>&1 &
fi
