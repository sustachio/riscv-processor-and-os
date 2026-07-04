#define LEDR   ((volatile unsigned int*)0x30000000)

__attribute__((section(".entry")))
void shell_main() {
  asm volatile ("ebreak");
  *LEDR = 16;
}