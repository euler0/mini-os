# mini-os #

This is my own implementation of an operating system for the x86 architecture.

## Prepare Development Environment in FreeBSD

1. Install GNU binutils for i686-elf target.
  ```
  /usr/ports/devel/cross-binutils # make TGTARCH=i686 TGTABI=elf install clean
  ```

2. Install QEMU emulator.
  ```
  /usr/ports/emulators/qemu # make -DBATCH install clean
  ```

## Or, in macOS

1. Install GNU binutils for i686-elf target.
  ```
  $ brew install i686-elf-binutils
  # or
  $ cd extra && ./prepare-binutils -t i686
  ```

2. Install QEMU emulator.
  ```
  $ brew install qemu
  ```

3. Install BSD Make.
  ```
  $ brew install bsdmake
  ```

## License ##

The project is released under the Simplified BSD License. For the formal details, see the file `LICENSE`.

## Acknowledgements

##### The FreeBSD Project #####

Copyright 1992-2013 The FreeBSD Project. All rights reserved.  
This project may adopt snippets of FreeBSD under the simplified BSD license. (http://www.freebsd.org/copyright/freebsd-license.html)
