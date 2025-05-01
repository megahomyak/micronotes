This is a dumb-simple Bash (?) script for managing a set of notes with synchronization through a remote server

File paths and file contents get encrypted with a key that you're supposed to share between your devices

The script itself is in `./micronotes.bash`. Check the file out and edit the configuration parameters to include the values fit for *you*. This is mandatory

DEPENDENCIES:
* bash (idk, maybe other shells will work too, haven't tested)
* openssl
* ssh

USAGE:
0. Ideally, `source` this into your `.bashrc`: `source /path/to/micronotes.bash`
1. Execute `mi note-path` (`mi` taken from `micronotes.bash`) to start editing a note with path `note-path`. For example, `mi todo`
2. The note will be downloaded from the remote server (if possible)
3. Your editor will open. Edit the received note
4. When you exit the editor, the note will be saved back to the server
