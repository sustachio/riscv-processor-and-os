#define LEDR   ((volatile unsigned int*)0x30000000)

__attribute__((section(".entry")))
void echo_main() {
  *LEDR = 8;
  while (1);
}