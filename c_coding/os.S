.section .text
.global enter_program
.global setup_mtvec
.global load_program

setup_mtvec:
  # a0 = trap handler address
  csrrw x0,mtvec,a0
  ret

enter_program:
  # a0 = program entry
  # a1 = stack top
  mv sp,a1

  # lower priv
  li t0,(3 << 11) # MPP = user
  csrrc zero,mstatus,t0

  csrrw zero,mepc,a0
  mret

load_program:
  # a0 - text_load
  # a1 - text_start
  # a2 - text_end

  # a3 - data_load
  # a4 - data_start
  # a5 - data_end

  # a6 - bss_start
  # a7 - bss_end

  # copy .text into RAM
1:
  bgeu a1, a2, 2f # done loading
  lw t0,0(a0) # from rom
  sw t0,0(a1) # to ram
  addi a1,a1,4
  addi a0,a0,4
  j 1b

  # copy .data into RAM
2:
  bgeu a4, a5, 3f # done loading
  lw t0,0(a3) # from rom
  sw t0,0(a4) # to ram
  addi a4,a4,4
  addi a3,a3,4
  j 2b

3:
  bgeu a6, a7, 4f # done loading
  sw zero,0(a6) # to ram
  addi a6,a6,4
  j 3b

4:
  ret