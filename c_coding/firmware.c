extern unsigned char __text_start, __text_end, __text_load;
extern unsigned char __data_start, __data_end, __data_load;
extern unsigned char __bss_start,  __bss_end;

__attribute__((section(".boot"))) 
void firmware_start(void) {
  char *src, *dst;

  src = &__text_load;
  dst = &__text_start;
  while (dst < &__text_end)
    *dst++ = *src++;

  src = &__data_load;
  dst = &__data_start;
  while (dst < &__data_end)
    *dst++ = *src++;

  dst = &__bss_start;
  while (dst < &__bss_end)
    *dst++ = 0;
}

/*
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
*/