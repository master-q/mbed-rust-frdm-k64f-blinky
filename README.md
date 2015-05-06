# Blinky for LPC1768 in rust with mbed

That's right mbed with rust! The mbed library consist of 2 parts - mbed API (C++ world) and mbed HAL - C layer (target + cmsis). The mbed library was built by GCC ARM, for K64F target. It's linked along with this application.

### How to build

Check out the related repositories.

```
$ git clone https://github.com/mbedmicro/mbed.git
$ git clone https://github.com/rust-lang/rust.git
$ git clone https://github.com/master-q/mbed-rust-frdm-k64f-blinky.git
```

Build mbed and copy the result.

```
$ cd mbed
$ python ./workspace_tools/build_travis.py
$ cp -a build ../mbed-rust-frdm-k64f-blinky/mbed
```

Build libcore.

```
$ cd ../mbed-rust-frdm-k64f-blinky
$ make libcore
$ file libcore.rlib
libcore.rlib: current ar archive
```

Build the project.

```
$ make
$ file mbed-blinky.elf
mbed-blinky.elf: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, not stripped
```

### Write firmware into your mbed LPC1768 board

Install pyOCD.

```
$ git clone https://github.com/walac/pyusb.git
$ git clone https://github.com/mbedmicro/pyOCD.git
$ (cd pyusb && sudo python setup.py install)
$ (cd pyOCD && sudo python setup.py install)
```

Run pyOCD gdbserver on a console.

```
$ sudo python pyOCD/test/gdb_server.py
--snip--
INFO:root:GDB server started at port:3333
```

Write firmware into your mbed LPC1768 board on the other console.

```
$ cd mbed-rust-frdm-k64f-blinky
$ make gdbwrite
##### Use me after running "sudo python pyOCD/test/gdb_server.py". #####
arm-none-eabi-gdb -x gdbwrite.boot mbed-blinky.elf
--snip--
(gdb) c
Continuing.
```

### Current status

It's work in progress.

- mbed rust API in the separate module (DigitalOut will be there, not part of this app)
- use cargo for everything (+ build script if required)
- target definitions - to have a complete definition for K64F target, the PinNames or other enums/macros.
- DigitalOut should be generic - currently gpio array is set to 4 (sizeof gpio_t for K64F), either to use dynamic allocation by mbed, or rust
- to have multiple mbed targets supported
- Makefile to build mbed library (only C code)
