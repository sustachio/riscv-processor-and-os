#include <stdint.h>
#include "keycodes.h"
#include "lib.h"
#include "mmio.h"

int main(void) {
  set_cursor(6,4);
  print("Hello, World!");
  set_cursor(11,6);
  print("^_^");

  return 0;
}