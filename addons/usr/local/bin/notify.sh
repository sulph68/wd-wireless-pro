#!/bin/bash

# cleanly terminate inotifywait if required
trap cleanup 1 2 5 9

if [ "$1" == "" ]; then
	echo "Directory not provided. Defaulting to /DataVolume/Data";
	DIR="/DataVolume/Data"
	[[ ! -d "${DIR}" ]] && mkdir -p "${DIR}"
fi

# $1 is the target directory we want to watch
[[ ! -d "${DIR}" ]] && echo "Notify watch directory does not exists!" && exit 1;
TARGET_DIR=$(realpath "${DIR}")
PREVIEW_DIR="/DataVolume/Preview"

[[ ! -d "${PREVIEW_DIR}" ]] && mkdir -p "${PREVIEW_DIR}"

cleanup() {
	local WATCHPID=$(pidof inotifywait)
	if [ "$?" = "0" ]; then
		echo "Recieved kill. Terminating inotifywait."
		kill -9 ${WATCHPID}
	fi
	echo "Exiting"
	exit 0
}

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
	# echo "Close: $2 , DIR: $1, Type: ${TYPE}, Preview: ${PREVIEW_FILE}" 
	# preview file doesn't exist. create it. Otherwise will just exit
	local EXT=${2##*.}
	# instructions for image types	
	if [ "${TYPE}" == "image" ]; then
		# specific instructions for image extensions
		if [ "${EXT,,}" == "heic" ]; then
			convert_heic "${1}${2}" "${PREVIEW_FILE}" > /dev/null
		elif [ "${EXT,,}" == "heif" ]; then
			convert_heic "${1}${2}" "${PREVIEW_FILE}" > /dev/null
		elif [ "${EXT,,}" == "jpg" ]; then
			convert_raw "${1}${2}" "${PREVIEW_FILE}" &> /dev/null
		elif [ "${EXT,,}" == "jpeg" ]; then
			convert_raw "${1}${2}" "${PREVIEW_FILE}" &> /dev/null
		elif [ "${EXT,,}" == "png" ]; then
			convert_raw "${1}${2}" "${PREVIEW_FILE}" &> /dev/null
		else
			# general instructions for images
			convert_raw "${1}${2}" "${PREVIEW_FILE}" > /dev/null
		fi
	elif [ "${TYPE}" == "video" ]; then
		# instructions for video types
		video_thumbnail "${1}${2}" "${PREVIEW_FILE}" > /dev/null
	else
		# instructions for any other types we want to support
		echo "No extra handler for (${EXT,,}): ${1}${$2}"
	fi
}

file_delete() {
	# clean up leftover files or directories in preview directory
	local PREVIEW_PATH=$(preview_path "$1")
	local PREVIEW_FILE=$(preview_file "$1" "$2")
	# echo "Delete: $2 , DIR: $1, Type: ${TYPE}" 
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
	# echo "$2 was attrib modified from $1" 
	# file touched. assume updated. regen.
	# [[ -f "${PREVIEW_FILE}" ]] && rm -f "${PREVIEW_FILE}"
	file_close "$1" "$2"
}

inotifywait --format "%w:%e:%f" -q -m -r -e close_write,attrib,delete "${TARGET_DIR}" | while IFS=':' read "DIRECTORY" "EVENT" "FILE"; do
	# echo "D: '$DIRECTORY', E: '$EVENT', F: '$FILE'"
	if [ ! -e "$DIRECTORY$FILE" ]; then
		# file is transient.
		# file_delete "$DIRECTORY" "$FILE"
		echo "File no longer found: ${DIRECTORY}${FILE}"
		continue
	fi
	# check file type for support
	TYPE=$(file_type "$DIRECTORY" "$FILE")
	if [ "${TYPE}" == "image" ]; then
		echo "N: Type supported: $TYPE, File: $FILE, Event: $EVENT"
	elif [ "${TYPE}" == "video" ]; then
		echo "N: Type supported: $TYPE, File: $FILE, Event: $EVENT"
	else 
		EXT=${FILE##*.}
		if [ "${EXT,,}" == "raw" ]; then
			echo "N: Cannot detect Mime (${TYPE}), (${EXT}) may be supported. Trying. File: $FILE"
			TYPE="image"
		elif [ "${EXT,,}" == "crw" ]; then
			echo "N: Cannot detect Mime (${TYPE}), (${EXT}) may be supported. Trying. File: $FILE"
			TYPE="image"
		elif [ "${EXT,,}" == "rmvb" ]; then
			echo "N: Cannot detect Mime (${TYPE}), (${EXT}) may be supported. Trying. File: $FILE"
			TYPE="video"
		else
			echo "Type not supported: $TYPE, File: $FILE"
			continue
		fi
	fi
	# put triggered events into a file pipe. lock it before writing
	(
	flock -n 9 || exit 1
	[[ ! -f /tmp/inotify.pipe ]] && touch /tmp/inotify.pipe
	grep "${EVENT}:${TYPE}:${DIRECTORY}:${FILE}" /tmp/inotify.pipe > /dev/null
	if [ "$?" = "1" ]; then
		echo "${EVENT}:${TYPE}:${DIRECTORY}:${FILE}" >> /tmp/inotify.pipe
	fi
	) 9>/tmp/inotify.pipe.lock
done &

# process the file pipe
while true; do
	if read "LOG" < /tmp/inotify.pipe; then
		# remove head of pipe. lock it before edit
		(
		flock -n 9 || exit 1
		sed '1d' /tmp/inotify.pipe > /tmp/inotify.pipe.tmp
		mv /tmp/inotify.pipe.tmp /tmp/inotify.pipe
		) 9>/tmp/inotify.pipe.lock
		# echo "${LOG}" 
		IFS=':' read "EVENT" "TYPE" "DIRECTORY" "FILE" <<< ${LOG}
		echo "P: Processing (${EVENT}) for (${TYPE}): ${DIRECTORY}${FILE}"
		case "${EVENT}" in
			CLOSE_WRITE*)
				# only genereate previews on close_write.
				file_close "${DIRECTORY}" "${FILE}"
				;;
			ATTRIB*)
				file_attrib "${DIRECTORY}" "${FILE}"
				;;
			DELETE*)
				file_delete "${DIRECTORY}" "${FILE}"
				;;
			*)
				echo "No handler: ${EVENT}"
				continue
				;;
		esac
	else
		sleep 1
	fi
done
