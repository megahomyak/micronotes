This is a dumb-simple Bash (?) script for managing a set of notes with synchronization through a remote server

File paths and file contents get encrypted with a key that you're supposed to share between your devices

DEPENDENCIES:
* bash (idk, maybe other shells will work too, haven't tested)
* openssl
* ssh
* GNU coreutils (at least "basenc", "cat", "mktemp")

INSTALLATION:
1. Download `./micronotes.bash`
2. Replace the values of parameter variables with the ones correct for you
3. `source` the file into your `.bashrc` or what have you: `source /path/to/micronotes.bash`
4. Create the directory where your notes will be stored, and either generate a new encryption key into it (`head -c 32 /dev/urandom > key.bin`) or copy an existing one from your other device
5. Don't forget to reload (likely, re-`source`) your shell's configuration, or just open a new shell

USAGE:
1. Execute `mi note-path` (`mi` taken from `micronotes.bash`) to start editing a note with path `note-path`. For example, `mi todo`
2. The note will be downloaded from the remote server (if possible)
3. Your editor will open. Edit the received note
4. When you exit the editor, the note will be saved back to the server
