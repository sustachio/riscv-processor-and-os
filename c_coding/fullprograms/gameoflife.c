#include <stdint.h>
#include "keycodes.h"

#define LEDR     ((volatile unsigned int*)0x30000000)
#define VGA      ((volatile unsigned int*)0x30000004)
#define KEYBOARD ((volatile unsigned char*)0x30000008)

#define SCREEN_X 40
#define SCREEN_Y 30

void *memset(void *dst, int c, unsigned long n)
{
    unsigned char *p = dst;
    while (n--)
        *p++ = (unsigned char)c;
    return dst;
}

void step_game(int board[SCREEN_X][SCREEN_Y]) {
  int neighbor_count[SCREEN_X][SCREEN_Y] = {0};
  for (int x=0;x<SCREEN_X;x++) {
    for (int y=0;y<SCREEN_Y;y++) {
      neighbor_count[x][y] = (
        ((1 <= x && 1 <= y)                 ? board[x-1][y-1] : 0) + // TL
        ((1 <= y)                           ? board[x]  [y-1] : 0) + // T
        ((x < SCREEN_X-1 && 1 <= y)         ? board[x+1][y-1] : 0) + // TR
        ((x < SCREEN_X-1)                   ? board[x+1][y]   : 0) + // R
        ((x < SCREEN_X-1 && y < SCREEN_Y-1) ? board[x+1][y+1] : 0) + // BR
        ((y < SCREEN_Y-1)                   ? board[x]  [y+1] : 0) + // B
        ((1 <= x && y < SCREEN_Y-1)         ? board[x-1][y+1] : 0) + // BL
        ((1 <= x)                           ? board[x-1][y]   : 0)   // L
      );
    }
  }

  for (int x=0;x<SCREEN_X;x++) {
    for (int y=0;y<SCREEN_Y;y++) {
      switch (neighbor_count[x][y]) {
        // underpopulation
        case 0:
        case 1:
          board[x][y] = 0;
          break;

        // survive (no change)
        case 2:
          break;

        // reproduction
        case 3:
          board[x][y] = 1;
          break;

        // overpopulation
        default:
          board[x][y] = 0;
          break;
      }
    }
  }
}

int main(void) {
  int draw_x = 0;
  int draw_y = 0;

  int r=7;
  int g=3;
  int b=3;
  int draw_color = ((r & 0x7) << 5) |
                    ((g & 0x7) << 2) |
                    (b & 0x3);

  // double buffer
  //int screen[SCREEN_X][SCREEN_Y] = {0};
  int board[SCREEN_X][SCREEN_Y] = {0}; // 1 for alive 0 for dead

  int last_left  = 0;
  int last_right = 0;
  int last_up    = 0;
  int last_down  = 0;
  int last_space = 0;
  int last_enter = 0;

  for (;;) {
    if (!last_left && KEYBOARD[KEY_LEFT_ARROW] && draw_x > 0)
      draw_x -= 1;
    if (!last_right && KEYBOARD[KEY_RIGHT_ARROW] && draw_x < SCREEN_X-1)
      draw_x += 1;
    if (!last_up && KEYBOARD[KEY_UP_ARROW] && draw_y > 0)
      draw_y -= 1;
    if (!last_down && KEYBOARD[KEY_DOWN_ARROW] && draw_y < SCREEN_Y-1)
      draw_y += 1;

    if (!last_space && KEYBOARD[KEY_SPACE])
      board[draw_x][draw_y] = 1 - board[draw_x][draw_y];

    if (!last_enter && KEYBOARD[KEY_ENTER])
      step_game(board);

    int space_pressed = KEYBOARD[KEY_SPACE];
    last_space = KEYBOARD[KEY_SPACE];
    last_left  = KEYBOARD[KEY_LEFT_ARROW];
    last_right = KEYBOARD[KEY_RIGHT_ARROW];
    last_up    = KEYBOARD[KEY_UP_ARROW];
    last_down  = KEYBOARD[KEY_DOWN_ARROW];
    last_enter = KEYBOARD[KEY_ENTER];



    for (int x=0; x<SCREEN_X; x++) {
      for (int y=0; y<SCREEN_Y; y++) {
        //*VGA = (x << 16) | (y << 8) | screen[x][y];
        int color = board[x][y] ? 0b11111111 : 0;
        color ^= (x == draw_x && y == draw_y) ? 0b10101010 : 0;
        *VGA = (x << 16) | (y << 8) | color;
      }
    }
  }

  return 0;
}