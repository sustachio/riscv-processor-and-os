module vga_interface(
  input rst_n,
  input clk,

  output reg [3:0] VGA_R,
  output reg [3:0] VGA_G,
  output reg [3:0] VGA_B,
  output reg VGA_HS,
  output reg VGA_VS,

  input [7:0] pen_x,
  input [7:0] pen_y,
  input [7:0] pen_color, // rgb332
  input pen_draw
);
  // horizontal timing (in pixles/25MHz clock cycles):
  // (0-95)    sync - 96
  // (96-143)  back porch (right after sync) - 48
  // (144-783) active video 640 (640 pixels wide)
  // (784-799) front porch (right before sync) - 16

  // vertical timing (in lines)
  // (0-1)     sync - 2
  // (2-32)    back porch - 31
  // (33-512)  active video - 480 (480 lines tall)
  // (513-523) front porch - 11

  // counters, not exactly pixles/lines, include porch/sync timing
  reg [9:0] x_counter;
  reg [9:0] y_counter;

  // 160 x 120
  wire [7:0] x_pixel = (x_counter - 144) >> 2;
  wire [7:0] y_pixel = (y_counter - 33)  >> 2;

  reg slower_clock;

  // pixel framebuffer, reads must be synchronous
  reg [7:0] pixels [0:19199]; // 160*120 // bigger than 40x30, weird so quartus may infer it?
  wire [14:0] pixel_addr = y_pixel * 160 + x_pixel;
  wire [14:0] pixel_write_addr = pen_y * 160 + pen_x;
  reg [7:0] pixel_data;

  always @(posedge clk) begin
    if (pen_x < 160 && pen_y < 120 && pen_draw && rst_n)
      pixels[pixel_write_addr] <= pen_color;

    pixel_data <= pixels[pixel_addr];
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      slower_clock <= 0;
      x_counter <= 0;
      y_counter <= 0;
    end else begin
      slower_clock <= ~slower_clock;

      if (slower_clock) begin
        if (x_counter >= 799) begin
          x_counter <= 0;

          if (y_counter >= 523) 
            y_counter <= 0;
          else
            y_counter <= y_counter + 1;
        end
        else
          x_counter <= x_counter + 1;
      end
    end
  end

  always @(*) begin
    VGA_HS = 1;
    VGA_VS = 1;
    VGA_R = 0;
    VGA_G = 0;
    VGA_B = 0;

    if (rst_n) begin
      // H sync
      if (x_counter <= 95)
        VGA_HS = 0;

      // V sync
      if (y_counter <= 1)
        VGA_VS = 0;

      // not in porches
      //if (144 <= x_counter && x_counter <= 783 &&
          //33  <= y_counter && y_counter <= 512) begin
      if (145 <= x_counter && x_counter <= 783 &&
          34  <= y_counter && y_counter <= 512) begin
        VGA_R = pixel_data[7:5] << 1;
        VGA_G = pixel_data[4:2] << 1;
        VGA_B = pixel_data[1:0] << 2;
      end
    end
  end
endmodule
