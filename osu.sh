#! /bin/sh
export WINEPREFIX="/home/wera/.wineosu"

if [[ -z "$1" ]]; then
	/opt/wine-osu/bin/wine C:/users/wera/AppData/Local/osu\!/osu\!.exe
fi

if [[ $1 == "config" ]]; then
	winecfg
fi

if [[ $1 == "tricks" ]]; then
	winetricks
fi

if [[ $1 == "kill" ]]; then
	wineserver -k
fi
