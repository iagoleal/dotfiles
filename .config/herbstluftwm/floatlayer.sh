#!/bin/sh

a=$(herbstclient list_monitors | grep two)

if [ "$a" == "" ]; then
	#replace '0' with name of your last tag
	herbstclient floating 10 on

	#change 1600x900 to match your resolution
	herbstclient add_monitor 1366x768 10 two
	
	#change to match your padding
	herbstclient pad two 20 0 0 0

	herbstclient lock_tag two

fi
