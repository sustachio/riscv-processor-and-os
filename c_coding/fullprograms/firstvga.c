#define LEDR   ((volatile unsigned int*)0x30000000)
#define VGA    ((volatile unsigned int*)0x30000004)

void main(void) {
    *LEDR = 0b101010101;

    for (int x=0; x<40; x++) {
      for (int y=0; y<30; y++) {
        if ((x + y) & 1)
          *VGA = (x << 16) | (y << 8) | (0b11111111);
        else
          *VGA = (x << 16) | (y << 8) | 0;
      }
    }

    while (1);
}

