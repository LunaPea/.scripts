#!/bin/sh

export DISPLAYY=:9
Xvfb $DISPLAYY &
x11vnc -display $DISPLAYY -localhost -bg
vncviewer :0 &
export DISPLAY=$DISPLAYY
audiorelay
