#!/bin/bash

# compile startup.S
riscv64-unknown-elf-gcc \
    -march=rv32i \
    -mabi=ilp32 \
    -c startup.S \
    -o startup.o \

# compile firmware
riscv64-unknown-elf-gcc \
  -march=rv32i \
  -mabi=ilp32 \
  -c firmware.c \
  -o output_files/firmware.o


# compile main.c
riscv64-unknown-elf-gcc \
    -march=rv32i \
    -mabi=ilp32 \
    -ffreestanding \
    -nostdlib \
    -T linker.ld \
    startup.S \
    lib.c \
    main.c \
    -lgcc \
    -o firmware.elf

# to binary
riscv64-unknown-elf-objcopy \
    -O binary \
    firmware.elf \
    firmware.bin

# print out
riscv64-unknown-elf-readelf -a firmware.elf
riscv64-unknown-elf-objdump \
    -D firmware.elf
