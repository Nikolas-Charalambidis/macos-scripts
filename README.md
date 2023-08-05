# macos-scripts
Utility scripts for MacOS

## ku
A small utility for common `kubectl` commands:
- `ku logs momma -n family`   Fetches the default number of logs lines from a first pod containing 'momma in the name in the 'family' namespace into a file in the default directory, and opens the log file.
- `ku spin momma -n family`   Deletes a first pod containing 'momma in the name in the 'family' namespace which makes Kubernetes deploy a new one up to the defined scale.

## up
TODO
