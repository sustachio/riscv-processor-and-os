ENTRY(firmware_start)

MEMORY
{
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4M 
  RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 512K
}

SECTIONS
{
  /* firmware */

  .boot ORIGIN(ROM) :
  {
    KEEP(*firmware.o(.boot))
  } > ROM

  /* os */

  /*.os.text ORIGIN(RAM) : AT(LOADADDR(.boot) + SIZEOF(.boot))*/
  .os.text :
  {
    __os_text_start = .;
    KEEP(*os.o(.entry))
    *os.o(.text*)
    *os_asm.o(.text*)
    *os.o(.rodata*)
    __os_text_end = .;
  } > RAM AT > ROM

  __os_text_load = LOADADDR(.os.text);

  .os.data :
  {
    __os_data_start = .;
    *os.o(.data)
    __os_data_end = .;
  } > RAM AT > ROM
  
  __os_data_load = LOADADDR(.os.data);

  .os.bss :
  {
      __os_bss_start = .;
      *os.o(.bss*)
      *os.o(COMMON)
      __os_bss_end = .;
  } > RAM

  .os.stack (NOLOAD) :
  {
    . = ALIGN(16);
    . += 4K;
    __os_stack_top = .;
  } > RAM

  /* program 0 */

  .shell.text __os_stack_top :
  {
    __shell_text_start = .;
    *shell.o(.entry)
    *shell.o(.text*)
    *shell.o(.rodata*)
    __shell_text_end = .;
  } > RAM AT > ROM

  __shell_text_load = LOADADDR(.shell.text);

  .shell.data :
  {
    __shell_data_start = .;
    *shell.o(.data)
    __shell_data_end = .;
  } > RAM AT > ROM
  
  __shell_data_load = LOADADDR(.shell.data);

  .shell.bss :
  {
      __shell_bss_start = .;
      *shell.o(.bss*)
      *shell.o(COMMON)
      __shell_bss_end = .;
  } > RAM


  /* program 1 */

  .echo.text __os_stack_top :
  {
    __echo_text_start = .;
    *echo.o(.entry)
    *echo.o(.text*)
    *echo.o(.rodata*)
    __echo_text_end = .;
  } > RAM AT > ROM

  __echo_text_load = LOADADDR(.echo.text);

  .echo.data :
  {
    __echo_data_start = .;
    *echo.o(.data)
    __echo_data_end = .;
  } > RAM AT > ROM
  
  __echo_data_load = LOADADDR(.echo.data);

  .echo.bss :
  {
      __echo_bss_start = .;
      *echo.o(.bss*)
      *echo.o(COMMON)
      __echo_bss_end = .;
  } > RAM

  __program_stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
