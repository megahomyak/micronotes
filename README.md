This is a simple Bash script for managing a set of notes with synchronization through a remote server

File paths and file contents get encrypted with a key that you're supposed to share between your devices

# Dependencies
* bash
* openssl
* ssh
* awk
* GNU coreutils (at least "basenc", "cat", "mktemp")

# Installation
1. Download `./micronotes.sh`
2. Make it executable if necessary (`chmod +x micronotes.sh`), then execute it (`./micronotes.sh`). For convenience, you can include a shortcut into your `.bashrc`: `alias mi=path/to/micronotes.sh` (and you can set environment variables there too using `export`)

# Usage
Please, refer to `./micronotes.sh --help`
