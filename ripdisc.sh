#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



# ---- Ubuntu Installation ----
# 1.HandBrake installation
#sudo add-apt-repository ppa:stebbins/handbrake-releases
#sudo apt-get update
#sudo apt-get install handbrake-cli
# NOTE : there is also handbrake-snapshots for dev versions

# 2.libdvdread & libdvdcss installation
#sudo apt-get install libdvdread4
#sudo /usr/share/doc/libdvdread4/install-css.sh



DISC_DEVICE="/dev/cdrom"
MOUNT_POINT="$_CURRENT_FILE_DIR/media"
OUTPUT_FILENAME="$1"

if [ "$1" == "-h" ]; then
	echo "$0 -h : help."
	echo "$0 <output_file[.m4v|mkv]> : specify a path to an output filename with an extension of m4v (DEFAULT) or mkv"
	exit
fi

if [ "$1" == "" ]; then
	echo "$0 -h for help."
	exit 1
fi


echo "Hello.."

# Closing disc
eject -t 2>/dev/null
sleep 15

echo "Mounting Disc."
mkdir -p "$MOUNT_POINT"
mount "$DISC_DEVICE" "$MOUNT_POINT"
sleep 2

rm -Rf "$OUTPUT_FILENAME".mkv
rm -Rf "$OUTPUT_FILENAME".m4v


echo "Starting process."
date1=$(date +"%s")

#AUDIO_EXCLUDE_REGEX="ACCEPT_ALL"
DEBUG="1" AUDIO_COPY="1" SUB_INCLUDE_REGEX='\b(?:English|Francais|Unknown|Closed\s+Captions)\b' AUDIO_EXCLUDE_REGEX='\b(?:Czech|Deutsch|Italiano|Magyar|Polish|Portugues|Thai|Turkish)\b' \
$_CURRENT_FILE_DIR/encode.pl $_CURRENT_FILE_DIR/media/ "$OUTPUT_FILENAME" main

date2=$(date +"%s")

echo "Process ended."
diff=$(($date2-$date1))
echo "Time elpased : $(($diff / 60)) minutes and $(($diff % 60)) seconds."

ls -al "$OUTPUT_FILENAME"*




echo "Unmounting Disc."
umount "$DISC_DEVICE"
eject

