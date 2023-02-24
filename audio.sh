#!/bin/sh

if ! pactl list modules | grep Virtual-Mic-Sink; then
  pactl load-module module-null-sink \
        sink_name=audiorelay-virtual-mic-sink \
        sink_properties=device.description=Virtual-Mic-Sink
fi
export DISPLAYY=:9
Xvfb $DISPLAYY &
x11vnc -display $DISPLAYY -localhost -bg
vncviewer :0 &
export DISPLAY=$DISPLAYY
audiorelay
