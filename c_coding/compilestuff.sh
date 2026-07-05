#!/bin/bash

# compile firmware
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -ffunction-sections \
  -fdata-sections \
  -c firmware.S \
  -o output_files/firmware.o

# compile OS
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -ffunction-sections \
  -fdata-sections \
  -c os.c \
  -o output_files/os.o
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -ffunction-sections \
  -fdata-sections \
  -c os.S \
  -o output_files/os_asm.o


# compile programs
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -ffunction-sections \
  -fdata-sections \
  -c shell.c \
  -o output_files/shell.o
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -ffunction-sections \
  -fdata-sections \
  -c echo.c \
  -o output_files/echo.o

# link all
riscv64-unknown-elf-gcc \
  -march=rv32i_zicsr \
  -mabi=ilp32 \
  -ffreestanding \
  -nostdlib \
  -static \
  -Wl,-Map=output_files/firware.map \
  -T linker.ld \
  output_files/firmware.o \
  output_files/os.o \
  output_files/shell.o \
  output_files/echo.o \
  output_files/os_asm.o \
  -lgcc \
  -o output_files/firmware.elf

# to binary
riscv64-unknown-elf-objcopy \
  -O binary \
  output_files/firmware.elf \
  output_files/firmware.bin

# print out
riscv64-unknown-elf-readelf -s output_files/firmware.elf
riscv64-unknown-elf-readelf -S output_files/firmware.elf
riscv64-unknown-elf-readelf -l output_files/firmware.elf
riscv64-unknown-elf-objdump -D output_files/firmware.elf
