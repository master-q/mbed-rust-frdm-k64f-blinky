# Copyright (c) 2015, Martin Kojtal (0xc0170)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LIBMBED   := mbed/mbed/TARGET_LPC1768/TOOLCHAIN_GCC_ARM
MBED_OBJS := $(LIBMBED)/*.o
MBED_LD   := $(LIBMBED)/LPC1768.ld
MBED_INC =  -Imbed/mbed
MBED_INC += -Imbed/mbed/TARGET_LPC1768
MBED_INC += -Imbed/mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X
MBED_INC += -Imbed/mbed/TARGET_LPC1768/TARGET_NXP/TARGET_LPC176X/TARGET_MBED_LPC1768

PROG := mbed-blinky

CC      := arm-none-eabi-gcc
AR      := arm-none-eabi-ar
LD      := arm-none-eabi-ld
GDB     := arm-none-eabi-gdb
RUSTC   := rustc

OPT  := 0
ARCH := thumbv7m
CPU  := cortex-m3

OBJCPY = arm-none-eabi-objcopy

RUSTFLAGS = -L . --target $(ARCH)-none-eabi -C target-cpu=$(CPU) 
RUSTFLAGS += -C relocation-model=static
RUSTFLAGS += -C opt-level=$(OPT) -g -Z no-landing-pads 
RUSTFLAGS += -A dead_code -A unused_variables 

LDFLAGS  = -mcpu=$(CPU) -mthumb -T $(MBED_LD)
LDFLAGS += -Wl,-Map=$(PROG).map,--cref -Wl,--wrap,main
LDFLAGS += -Wl,--gc-sections --specs=nano.specs #-Wl,-print-gc-sections
# LDFLAGS += -L /usr/lib/arm-none-eabi/newlib -L /usr/lib/arm-none-eabi/newlib/armv7-m #-print-gc-sections
LDFLAGS += -L . src/mbed-rust-frdm-k64-blinky.o src/gpio_stub.o $(MBED_OBJS)
LDFLAGS += -Wl,--start-group -L$(LIBMBED) -lmbed -lstdc++ -lsupc++ -lm -lc -lgcc -Wl,--end-group

.SUFFIXES: .o .rs .c

all: $(PROG).elf $(PROG).bin print_info

.rs.o:
	$(RUSTC) $(RUSTFLAGS) --emit obj -o $@ $<

.c.o:
	$(CC) -mcpu=$(CPU) -mthumb -c -o $@ $< $(MBED_INC)

$(PROG).elf: src/mbed-rust-frdm-k64-blinky.o src/gpio_stub.o
	$(CC) $(LDFLAGS) /usr/lib/gcc/arm-none-eabi/4.8/libgcc.a -o $@

$(PROG).bin: $(PROG).elf
	$(OBJCPY) -O binary $< $@

libcore: libcore.rlib

libcore.rlib:
	$(RUSTC) $(RUSTFLAGS) ../rust/src/libcore/lib.rs

print_info:
	arm-none-eabi-size --totals $(PROG).elf

.PHONY: clean

clean:
	rm -f src/*.o $(PROG).bin $(PROG).elf

gdbwrite: $(PROG).elf
	@echo '##### Use me after running "sudo python pyOCD/test/gdb_server.py". #####'
	$(GDB) -x gdbwrite.boot $(PROG).elf
