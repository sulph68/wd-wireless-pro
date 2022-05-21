#!/bin/bash

IFS='\n:'

if [ "$1" == "" ]; then
	echo "Directory not provided. Defaulting to /DataVolume/Data";
	DIR="/DataVolume/Data"
	[[ ! -d "${DIR}" ]] && mkdir -p "${DIR}"
fi

# $1 is the target directory we want to watch
[[ ! -d "${DIR}" ]] && echo "Notify watch directory does not exists!" && exit 1;
TARGET_DIR=`realpath "${DIR}"`
PREVIEW_DIR="/DataVolume/Preview"

[[ ! -d "${PREVIEW_DIR}" ]] && mkdir -p "${PREVIEW_DIR}"

file_type() {
	local FILE="$2"
	local DIR="$1"
	local FULLPATH="$1/$2"
	local TYPE=`exiftool -mimetype -S "${FULLPATH}" | awk -F"(: |\/)" '{print $2}'`
	echo "$TYPE"
}

preview_path() {
	local PREVIEW_PATH=`echo "$1" | sed "s|${TARGET_DIR}|${PREVIEW_DIR}|"`
	echo "$PREVIEW_PATH"
}

preview_file() {
	local PREVIEW_PATH=$(preview_path "$1")
	local EXT=${2##*.}
	if [ "${EXT,,}" != "jpg" ]; then
		FILENAME="${2}.jpg"
	else
		FILENAME="${2}"
	fi
	echo "$PREVIEW_PATH${FILENAME}"
}

file_close() {
	# event here should be close_write.
	# generate preview
	local PREVIEW_PATH=$(preview_path "$1")
	local PREVIEW_FILE=$(preview_file "$1" "$2")
	[[ ! -d "${PREVIEW_PATH}" ]] && mkdir -p "${PREVIEW_PATH}"
	echo "Close: $2 , DIR: $1, Type: ${TYPE}, Preview: ${PREVIEW_FILE}" 
	# preview file doesn't exist. create it. Otherwise will just exit
	local EXT=${2##*.}
	if [ ! -f "${PREVIEW_FILE}" ]; then
		if [ "${TYPE}" == "image" ]; then
			if [ "${EXT,,}" == "heic" ]; then
				convert_heic "${1}${2}" "${PREVIEW_FILE}"
			elif [ "${EXT,,}" == "heif" ]; then
				convert_heic "${1}${2}" "${PREVIEW_FILE}"
			else
				convert_raw "${1}${2}" "${PREVIEW_FILE}"
			fi
		else
			if [ "${EXT,,}" == "raw" ]; then
				convert_raw "${1}${2}" "${PREVIEW_FILE}"
			fi
		fi
	fi
}

file_delete() {
	# clean up leftover files or directories in preview directory
	local PREVIEW_PATH=$(preview_path "$1")
	local PREVIEW_FILE=$(preview_file "$1" "$2")
	echo "Delete: $2 , DIR: $1, Type: ${TYPE}" 
	[[ -f "${PREVIEW_FILE}" ]] && rm -f "${PREVIEW_FILE}"
	[[ ! -d "${PREVIEW_PATH}" ]] && return
	if [ $(ls -A "${PREVIEW_PATH}") ]; then
		# not empty
		echo "Dir not empty: ${PREVIEW_PATH}"
	else
		# empty
		if [ "${PREVIEW_PATH}" != "${PREVIEW_DIR}/" ]; then
			echo "Cleaning up empty directory: ${PREVIEW_PATH}"
			rmdir "${PREVIEW_PATH}"
		fi
	fi
}

file_attrib() {
	# file attrib has been modified. but should be same as close_write?
	local PREVIEW_PATH=$(preview_path "$1")
	local PREVIEW_FILE=$(preview_file "$1" "$2")
	echo "$2 was attrib modified from $1" 
	# file touched. assume updated. regen.
	[[ -f "${PREVIEW_FILE}" ]] && rm -f "${PREVIEW_FILE}"
	file_close "$1" "$2"
}

file_modify() {
	# file has been modified. but should be same as close_write?
	echo "$2 was modified from $1" 
}

file_create() {
	# know a file has been created. do we even care?
	echo "Create: $2 , DIR: $1, Type: ${TYPE}" 
}

file_move() {
	# check source and destination. cleanup after
	echo "Move: $2 , DIR: $1, Type: ${TYPE}" 
}

inotifywait --format "%w:%e:%f" -q -m -r -e create,close_write,attrib,move,delete "${TARGET_DIR}" | while read DIRECTORY EVENT FILE; do
	# echo "D $DIRECTORY with E $EVENT on F $FILE"
	if [ ! -e "$DIRECTORY/$FILE" ]; then
		# file is transient.
		file_delete "$DIRECTORY" "$FILE"
		continue
	fi
	# check file type for support
	TYPE=$(file_type "$DIRECTORY" "$FILE")
	if [ "${TYPE}" == "image" ]; then
		echo "Type supported: $TYPE, File: $FILE, Event: $EVENT"
	elif [ "${TYPE}" == "video" ]; then
		echo "Type supported: $TYPE, File: $FILE, Event: $EVENT"
	else 
		EXT=${FILE##*.}
		if [ "${EXT,,}" == "raw" ]; then
			echo "Cannot detect Mime, (${EXT}) may be supported. Trying. File: $FILE"
		else
			echo "Type not supported: $TYPE, File: $FILE"
			continue
		fi
	fi
	case $EVENT in
		CREATE*)
			file_create "$DIRECTORY" "$FILE"
			;;
		MOVE*)
			file_move "$DIRECTORY" "$FILE"
			;;
		CLOSE_WRITE*)
			# only genereate previews on close_write.
			file_close "$DIRECTORY" "$FILE"
			;;
		ATTRIB*)
			file_attrib "$DIRECTORY" "$FILE"
			;;
		MODIFY*)
			file_modify "$DIRECTORY" "$FILE"
			;;
		DELETE*)
			file_delete "$DIRECTORY" "$FILE"
			;;
		*)
			echo "No handling event"
			continue
			;;
	esac
done
