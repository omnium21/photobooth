#!/bin/sh

export LC_ALL=C
export LANG=C

##
## PB_DIR Should be the location of the install
## We could take this from $0
##
PB_DIR=$( cd "$( dirname "$0" )" && pwd )

DATA_DIR=/home/$USER/pbdata
PHOTOS_DIR=$DATA_DIR/photos
LOGS_DIR=$DATA_DIR/logs

mkdir -p $PHOTOS_DIR $LOGS_DIR

##
## Disable the cursor so it doesn't interfere with the screen
##

setterm -cursor off > /dev/tty1

##
## Catch any extra output to prevent output on our console screen
## (our Image viewer)
##

exec > file 2>&1


##
## Show a default 'boot splash image'
##

$PB_DIR/showjpg $PB_DIR/photobooth.jpg


##
## iwatch (from inotify) monitors $PHOTOS_DIR and
## updates the screen whenever a new picture appears.
##
## This just runs in the background...
##

iwatch -e moved_to \
	-c "$PB_DIR/showjpg %f" \
	$PHOTOS_DIR 2>&1 >> $LOGS_DIR/iwatch.log &

##
## Use gphoto2 to download anything generated by the camera
## automatically, and save in the PWD ($PHOTOS_DIR)
##

cd $PHOTOS_DIR

while true;
do
	yes | gphoto2 --wait-event-and-download 2>&1 >> $LOGS_DIR/photobooth.log;
	sleep 1;
done 2>&1 > /dev/null

