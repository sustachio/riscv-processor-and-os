ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
    .boot :
    {
      KEEP(*(.boot))
    } > ROM

    .text ORIGIN(RAM) : AT(LOADADDR(.boot) + SIZEOF(.boot))
    {
      __text_start = .;
      *(.text*)
      *(.rodata*)
      __text_end = .;
    } > RAM

    __text_load = LOADADDR(.text);

    .data :
    {
      __data_start = .;
      *(.data*)
      __data_end = .;
    } > RAM AT > ROM
    
    __data_load = LOADADDR(.data);

    .bss :
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } > RAM

    .stack (NOLOAD) :
    {
      . = ALIGN(16);
      __stack_top = ORIGIN(RAM) + LENGTH(RAM);
    } > RAM
}
