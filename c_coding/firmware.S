.section .boot,"ax",@progbits
.global firmware_start

firmware_start:
  # stack
  la sp, __os_stack_top

  # copy .text into RAM
  la t0, __os_text_load
  la t1, __os_text_start
  la t2, __os_text_end

1:
  bgeu t1, t2, 2f # done loading
  lw t3,0(t0) # from rom
  sw t3,0(t1) # to ram
  addi t1,t1,4
  addi t0,t0,4
  j 1b

2:
  # copy .data into RAM
  la t0, __os_data_load
  la t1, __os_data_start
  la t2, __os_data_end

1:
  bgeu t1, t2, 2f # done loading
  lw t3,0(t0) # from rom
  sw t3,0(t1) # to ram
  addi t1,t1,4
  addi t0,t0,4
  j 1b

2:
  # clear bss
  la t0, __os_bss_start
  la t1, __os_bss_end

1:
  bgeu t0, t1, 2f # done loading
  sw zero,0(t0) # to ram
  addi t0,t0,4
  j 1b

2:
  la t0,__os_text_start
  ebreak
  call __os_text_start

3:
  j 3b