.section .boot, "ax", @progbits
.global _start

_start:
  # stack
  la sp, __stack_top

  # copy .text into RAM
  la t0, __text_load
  la t1, __text_start
  la t2, __text_end

1:
  beq t1, t2, 2f # done loading
  lw t3,0(t0) # from rom
  sw t3,0(t1) # to ram
  addi t1,t1,4
  addi t0,t0,4
  j 1b

2:
  # copy .data into RAM
  la t0, __data_load
  la t1, __data_start
  la t2, __data_end

1:
  beq t1, t2, 2f # done loading
  lw t3,0(t0) # from rom
  sw t3,0(t1) # to ram
  addi t1,t1,4
  addi t0,t0,4
  j 1b

2:
  # clear bss
  la t0, __bss_start
  la t1, __bss_end

1:
  beq t0, t1, 2f # done loading
  sw zero,0(t0) # to ram
  addi t0,t0,4
  j 1b

2:
  call main

3:
  j 3b
