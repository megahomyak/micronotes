#!/bin/bash -euo pipefail
LOCAL_FILE_PATH="$1"
HELP_MESSAGE='Usage: ./micronotes.sh [NOTE PATH]
Edit a note file with synchronization through a central server.

[NOTE PATH] is the path to your note relative to MICRONOTES_LOCAL_DIR. If no note with the specified path is present, one will be created.'
check_all_parameter_presence() {
    check_parameter_presence() {

    }
    if [[ ! -v MICRONOTES_REMOTE_DIR ]] || [[ ! -v MICRONOTES_LOCAL_DIR ]] || [[ ! -v MICRONOTES_REMOTE_CREDENTIALS ]]; then
        if [[ ! -v MICRONOTES_REMOTE_DIR ]]; then
            echo 'MISSING PARAMETER `MICRONOTES_LOCAL_DIR`: responsible'
        fi
        exit
    fi
}
if [[ "$LOCAL_FILE_PATH" == "" || "$LOCAL_FILE_PATH" == "-h" || "$LOCAL_FILE_PATH" == "--help" ]]; then
    echo "$HELP_MESSAGE" >&2
    check_all_parameter_presence
    exit
fi
check_all_parameter_presence
enc() {
    openssl enc -aes-256-cbc -pass file:key.bin -pbkdf2 "$@"
}
cd MICRONOTES_LOCAL_DIR
mi() (
    cd ~/micronotes # Wherever you want; this directory should contain a `key.bin`, which can be generated using `head -c 32 /dev/urandom > key.bin`
    REMOTE_DIR="micronotes" # Wherever you want
    REMOTE_CREDENTIALS="orange" # Whatever you have
    LOCAL_FILE_PATH="$1"
    if [ "$LOCAL_FILE_PATH" = "" ]
    then
        echo 'You forgot to provide the file path' >&2
        exit
    fi
    enc() {
        openssl enc -aes-256-cbc -pass file:key.bin -pbkdf2 "$@"
    }
    REMOTE_FILE_NAME="$(echo "$LOCAL_FILE_PATH" | enc -nosalt | basenc --base64url)"
    REMOTE_FILE_PATH="$REMOTE_DIR/$REMOTE_FILE_NAME"
    TEMP_LOCAL_FILE_PATH="$(mktemp)"
    if ssh "$REMOTE_CREDENTIALS" "mkdir -p $REMOTE_DIR && cat $REMOTE_FILE_PATH" | enc -d > "$TEMP_LOCAL_FILE_PATH"
    then
        mv "$TEMP_LOCAL_FILE_PATH" "$LOCAL_FILE_PATH"
    else
        rm "$TEMP_LOCAL_FILE_PATH"
    fi
    "$EDITOR" "$LOCAL_FILE_PATH"
    cat "$LOCAL_FILE_PATH" | enc | ssh "$REMOTE_CREDENTIALS" "cat > $REMOTE_FILE_PATH"
)
