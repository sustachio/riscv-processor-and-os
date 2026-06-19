#include <stdint.h>

#include "lib.h"
#include "mmio.h"
#include "ascii.h"

void *memset(void *dst, int c, unsigned long n)
{
    unsigned char *p = dst;
    while (n--)
        *p++ = (unsigned char)c;
    return dst;
}

// 5x8  char grid
// 6x10 total, padding: 1 top, 1 bottom, 1 right
void display_char(char c, int x, int y) {
  uint8_t* grid = LETTERS_5x8[(unsigned char)c];
  x = x * 6;
  y = y * 10;

  // top/bottom padding
  for (int x_offset = 0; x_offset < 6; x_offset++) {
    *VGA = ((x + x_offset) << 16) | (y     << 8) | 0;
    *VGA = ((x + x_offset) << 16) | ((y+9) << 8) | 0;
  }
  // right padding
  for (int y_offset = 0; y_offset < 10; y_offset++)
    *VGA = ((x + 5) << 16) | ((y + y_offset) << 8) | 0;

  for (int x_offset=0; x_offset < 5; x_offset++) {
    __asm__ volatile ("ebreak");
    uint8_t col = grid[x_offset];
    *LEDR = col;

    for (int y_offset=1; y_offset < 9; y_offset++) {
      *VGA = (
        ((x + x_offset) << 16) | 
        ((y + y_offset) << 8) | 
        (((col >> (8-y_offset)) & 1) ? 0b11111111 : 0));
    }
  }
}

cursor_x = 0;
cursor_y = 0;
void set_cursor(int x, int y) {
  cursor_x = x;
  cursor_y = y;
};

void print(char* s) {
  unsigned int i = 0;

  while (s[i] != '\0') {
    display_char(s[i], cursor_x, cursor_y);

    if (++cursor_x > 25) {
      cursor_x = 0;
      cursor_y++;
    }

    i++;
  }
}