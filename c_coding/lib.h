#ifndef LIB_H
#define LIB_H

void *memset(void *dst, int c, unsigned long n);

// text display
extern int cursor_x;
extern int cursor_y;
void display_char(char c, int x, int y);
void set_cursor(int x, int y);
void print(char* s);

#endif