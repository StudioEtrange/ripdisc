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



MOUNT_POINT="$_CURRENT_FILE_DIR/media"
OUTPUT_FILENAME="$3"


if [ "$1" = "-h" ]; then
	echo "$0 -h : help."
	echo "$0 disc <device> <output_file[.m4v|mkv] path> : first arg : device where disc is inserted (ie /dev/cdrom). second arg : specify a path to an output filename with an extension of m4v (DEFAULT) or mkv"
	echo "$0 iso <iso path> <output_file[.m4v|mkv] path> : first arg : iso path (ie /foo/bar/file.iso). second arg : specify a path to an output filename with an extension of m4v (DEFAULT) or mkv"
	echo "$0 folder <dvd folder> <output_file[.m4v|mkv] path> : first arg : folder where DVD files (AUDIO_TS and VIDEO_TS folders) resides (ie /foo/bar). second arg : specify a path to an output filename with an extension of m4v (DEFAULT) or mkv"
	exit
fi

if [ "$1" = "" ]; then
	echo "$0 -h for help."
	echo "NOTE : run as sudo"
	echo "SAMPLES :"
	echo '	sudo ./ripdisc.sh folder "../download/complete/movie/MOVIE_SPECIAL_EDITION" ../output/movie_multi_dvdrip.mkv'
	echo '	sudo ./ripdisc.sh disc "/dev/cdrom" ../output/movie_multi_dvdrip.mkv'
	echo '	sudo ./ripdisc.sh iso "../download/iso/movie.iso" ../output/movie_multi_dvdrip.mkv'

	exit 1
fi


echo "Hello.."

# NOTE: this is  here because encode.pl script have hardcoded localtion of HandBrakeCli..
mkdir -p $HOME/bin/video
ln -s $(which HandBrakeCLI) $HOME/bin/video/HandBrakeCLI 2>/dev/null



mkdir -p "$MOUNT_POINT"

if [ "$1" = "disc" ]; then
	# Closing disc
	eject -t 2>/dev/null
	sleep 15

	DISC_DEVICE="$2"
	echo "Mounting Disc from $DISC_DEVICE to $MOUNT_POINT"
	mount "$DISC_DEVICE" "$MOUNT_POINT"
	sleep 2

fi


if [ "$1" = "iso" ]; then
	ISO_PATH="$2"
	echo "Mounting ISO from $ISO_PATH to $MOUNT_POINT"
	mount -o loop -t iso9660 "$ISO_PATH" "$MOUNT_POINT"
fi

if [ "$1" = "folder" ]; then
	MOUNT_POINT="$2"
fi

rm -Rf "$OUTPUT_FILENAME".mkv
rm -Rf "$OUTPUT_FILENAME".m4v


echo "Starting process."
date1=$(date +"%s")

#AUDIO_EXCLUDE_REGEX="ACCEPT_ALL"
#AUDIO_EXCLUDE_REGEX='\b(?:Czech|Deutsch|Italiano|Magyar|Polish|Portugues|Thai|Turkish)\b'
# SUB_INCLUDE_REGEX='\b(?:English|Francais|Unknown|Closed\s+Captions)\b'
#ENCODER="x264"
#ENCODER="x265"
ENCODER="x264" DEBUG="1" AUDIO_COPY="1" AUDIO_EXCLUDE_REGEX='ACCEPT_ALL' \
$_CURRENT_FILE_DIR/encode.pl "$MOUNT_POINT" "$OUTPUT_FILENAME" main

date2=$(date +"%s")

echo "Process ended."
diff=$(($date2-$date1))
echo "Time elpased : $(($diff / 60)) minutes and $(($diff % 60)) seconds."





if [ "$1" = "disc" ]; then
	echo "Unmounting Disc."
	umount "$DISC_DEVICE"
	eject
fi

if [ "$1" = "iso" ]; then
	echo "Unmounting ISO."
	umount "$ISO_PATH"
fi

