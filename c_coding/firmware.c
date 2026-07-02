extern unsigned char __os_text_start, __os_text_end, __os_text_load;
extern unsigned char __os_data_start, __os_data_end, __os_data_load;
extern unsigned char __os_bss_start,  __os_bss_end;

typedef void (*entry_t)(void);

__attribute__((section(".boot")))
void firmware_start() {
  char *src, *dst;

  // text load
  src = &__os_text_load;
  dst = &__os_text_start;
  while (dst < &__os_text_end)
    *dst++ = *src++;

  // data load
  src = &__os_data_load;
  dst = &__os_data_start;
  while (dst < &__os_data_end)
    *dst++ = *src++;

  // bss clear
  dst = &__os_bss_start;
  while (dst < &__os_bss_end)
    *dst++ = 0;

  // woah this is neat
  entry_t os = (entry_t)&__os_text_start;
  os();

  for (;;);
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