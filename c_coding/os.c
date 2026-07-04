#include <stdint.h>

#define LEDR   ((volatile unsigned int*)0x30000000)

#define SHELL 0
#define ECHO 1

// defined in linker
extern char __shell_text_start, __shell_text_end, __shell_text_load;
extern char __shell_data_start, __shell_data_end, __shell_data_load;
extern char __shell_bss_start,  __shell_bss_end;

extern char __echo_text_start,  __echo_text_end,  __echo_text_load;
extern char __echo_data_start,  __echo_data_end,  __echo_data_load;
extern char __echo_bss_start,   __echo_bss_end;

extern char __program_stack_top;

// defined in asm
extern void enter_program(void* addr, void* sp);
extern void setup_mtvec(void* addr);
extern void load_program(
  char* text_load,
  char* text_start,
  char* text_end,

  char* data_load,
  char* data_start,
  char* data_end,

  char* bss_start,
  char* bss_end
);

void trap_handler(uint32_t what, uint32_t a, uint32_t b) {
  *LEDR = what + 1;

  // return to program
}

void run_program(uint32_t program_id) {
  char* program_entry;

  if (program_id == SHELL) {
    load_program(
      (char*)&__shell_text_load,
      (char*)&__shell_text_start,
      (char*)&__shell_text_end,

      (char*)&__shell_data_load,
      (char*)&__shell_data_start,
      (char*)&__shell_data_end,

      (char*)&__shell_bss_start,
      (char*)&__shell_bss_end
    );

    program_entry = (char*)&__shell_text_start;
  } 
  else if (program_id == ECHO) {
    load_program(
      (char*)&__echo_text_load,
      (char*)&__echo_text_start,
      (char*)&__echo_text_end,

      (char*)&__echo_data_load,
      (char*)&__echo_data_start,
      (char*)&__echo_data_end,

      (char*)&__echo_bss_start,
      (char*)&__echo_bss_end
    );

    program_entry = (char*)&__shell_text_start;
  }
  else // reboot
    program_entry = 0;

  asm volatile (
    "mv a0,%0"
    :
    : "r" (program_entry)
    :
  ); // load program entry into a0
  asm volatile ("ebreak");

  enter_program(&__shell_text_start, &__program_stack_top);
}

__attribute__((section(".entry")))
void os_entry() {
  asm volatile ("ebreak");

  setup_mtvec((void*)trap_handler);
  run_program(SHELL);

  while (1);
}