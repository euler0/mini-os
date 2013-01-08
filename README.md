# mini-os #

This is my own implementation of a operating system for the x86 architecture. There's no official name for the project, and never will be. The project will always be self-taught, unstable, and stupid :) Any feedbacks are much appreciated.

## Prepare Development Environment in FreeBSD

1. Install GNU binutils for i686-elf target.
  ```
  /usr/ports/devel/cross-binutils # make TGTARCH=i686 TGTABI=elf install clean
  ```

2. Install QEMU emulator.
  ```
  /usr/ports/emulators/qemu # make -DBATCH install clean
  ```

## Or, in OS X

1. Install GNU binutils for i686-elf target.
  ```
  $ cd extra && ./prepare-binutils
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
