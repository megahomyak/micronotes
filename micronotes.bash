#!/bin/bash
mi() (
    set -euo pipefail
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
