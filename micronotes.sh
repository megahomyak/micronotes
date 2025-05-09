#!/bin/bash
set -euo pipefail
LOCAL_FILE_PATH="${1:-}"
if [[ "$LOCAL_FILE_PATH" == "" || "$LOCAL_FILE_PATH" == "-h" || "$LOCAL_FILE_PATH" == "--help" ]]; then
    cat << EOF
Usage: ./micronotes.sh [NOTE PATH]
Edit a note file with synchronization through a central server.

[NOTE PATH] is the path to your note relative to MICRONOTES_LOCAL_DIR. If no note with the specified path is present, one will be downloaded from the server if present there or created if not.

After the note is downloaded, it will be opened in an editor and sent back to the server when you exit the editor.

On the editing stage, if you make the note only contain whitespace characters or contain nothing and exit the editor, the note will be deleted both locally and remotely.

All the notes' contents and paths will be encrypted using a key in the "key.bin" file in MICRONOTES_LOCAL_DIR. You can create the file using "head -c 32 /dev/urandom > key.bin".

Required environment variables:
1. MICRONOTES_LOCAL_DIR - a path to a directory on your machine where the notes will be stored
2. MICRONOTES_REMOTE_CREDENTIALS - a second argument to "ssh" to enter the remote synchronization server
3. MICRONOTES_REMOTE_DIR - a directory on the synchronization server where the notes will be stored encrypted.
EOF
    exit
fi
cd "$MICRONOTES_LOCAL_DIR"
enc() {
    openssl enc -aes-256-cbc -pass file:key.bin -pbkdf2 "$@"
}
enc_det() { # Deterministic, non-authenticated symmetrical encryption. Reads from stdin, writes into stdout
    TODO
}
enc_ndet() { # Non-deterministic, authenticated symmetrical encryption. Reads from stdin, writes into stdout
    TODO
}
dec() { # Decryption of output of enc_ndet(). Reads from stdin, writes into file by path from $1
    OUT_FILE_PATH="$1"
    TODO
}
REMOTE_FILE_NAME="$(echo "$LOCAL_FILE_PATH" | enc_det | basenc --base64url)"
REMOTE_FILE_PATH="$MICRONOTES_REMOTE_DIR/$REMOTE_FILE_NAME"
TEMP_LOCAL_FILE_PATH="$(mktemp)"
ssh_remote() {
    ssh "$MICRONOTES_REMOTE_CREDENTIALS" "$@"
}
escape() {
    printf '%q' "${!1}"
}
if ssh_remote "mkdir -p $(escape MICRONOTES_REMOTE_DIR) && cat $(escape REMOTE_FILE_PATH)" | dec "$TEMP_LOCAL_FILE_PATH"; then
    mv "$TEMP_LOCAL_FILE_PATH" "$LOCAL_FILE_PATH"
else
    rm "$TEMP_LOCAL_FILE_PATH"
fi
"$EDITOR" "$LOCAL_FILE_PATH"
if [ -f "$LOCAL_FILE_PATH" ]; then
    if awk "NF { exit 1 }" "$LOCAL_FILE_PATH"; then
        rm "$LOCAL_FILE_PATH"
        ssh_remote "rm $(escape REMOTE_FILE_PATH)" || true
    else
        cat "$LOCAL_FILE_PATH" | enc_ndet | ssh_remote "cat > $(escape REMOTE_FILE_PATH)"
    fi
fi
