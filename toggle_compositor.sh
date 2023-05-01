#!/bin/bash

if [ $(ps -ax|grep picom|grep -v grep|wc -l) -gt '0' ]; then
	echo "killing picom"
	killall picom
else
	echo "launching picom"
	nohup picom&
fi
