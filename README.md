# macos-scripts
A collection of utility scripts for MacOS

## ku
A small utility for common `kubectl` commands:
- `ku logs momma -n family`   Fetches the default number of logs lines from a first pod containing `momma` in the name in the `family` namespace into a file in the default directory, and opens the log file.
- `ku spin momma -n family`   Deletes a first pod containing 'momma in the name in the 'family' namespace making Kubernetes deploy a new one up to the defined scale.

Installation: Copy the script file to an executable location of `$PATH`. Find this [StackOverflow](https://stackoverflow.com/q/3560326/3764965) question for more information. 

## up
TODO

Installation: Copy the script file to an executable location of `$PATH`. Find this [StackOverflow](https://stackoverflow.com/q/3560326/3764965) question for more information. Additionally, it is needed to create an alias `alias up=". up"`. Find this [StackOverflow](https://stackoverflow.com/q/255414/3764965) question for more information.
