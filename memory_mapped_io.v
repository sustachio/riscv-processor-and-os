// this is pretty inneficent but matches timing of other memory elements + buffer time for holding
module memory_mapped_io(
	input  wire clk,
	input  wire rst_n,
	
	input  wire read_request,
	input  wire write_request,
	input  wire [31:0] addr,
	input  wire [31:0] data_in,
	
	output reg [31:0] data_out,
	output reg finished,
	
	output reg busy,

  // interfaces
  output reg [9:0] LEDR,

  output reg [7:0] vga_pen_x,
  output reg [7:0] vga_pen_y,
  output reg [7:0] vga_pen_color,
  output reg vga_pen_draw,

  output reg [6:0] ps2_get_key,
  input ps2_key_pressed
);
	// states
	localparam IDLE  = 3'd0;
	localparam WRITE_LEDR = 3'd1;
  localparam WRITE_VGA  = 3'd2;
  localparam READ_PS2  = 3'd3;
	
	reg [2:0] state = IDLE;
	reg [2:0] next_state = IDLE;

	// FSM
	always @(*) begin
    if (!rst_n)
      next_state = IDLE;
    else begin
      next_state = state;
      case (state)
        IDLE: begin
          if (write_request && addr == 32'h30000000)
            next_state = WRITE_LEDR;
          else if (write_request && addr == 32'h30000004)
            next_state = WRITE_VGA;
          else if (read_request && addr >= 32'h30000008 && addr <= 32'h3000006E)
            next_state = READ_PS2;
        end
      
        WRITE_LEDR:
          next_state = IDLE;

        WRITE_VGA:
          next_state = IDLE;

        READ_PS2:
          next_state = IDLE;

        default: begin end
      endcase
    end
	end
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
			finished <= 0;
			data_out <= 0;
			busy <= 0;

      vga_pen_x <= 8'd0;
      vga_pen_y <= 8'd0;
      vga_pen_color <= 8'd0;
      vga_pen_draw <= 1'b0;

      ps2_get_key <= 7'd0;
		end else begin
			// FSM transitions
      if (next_state == IDLE) begin
        busy <= 0;
        finished <= 1;

        vga_pen_draw <= 0;
      end

			if (next_state != state) begin
        if (state == IDLE) begin
          busy <= 1;
          finished <= 0;
          data_out <= 0;
        end

				case (next_state)
          // read results
          IDLE: begin
            if (state == READ_PS2)
              data_out <= {31'd0, ps2_key_pressed};
          end

          // write do things / read initialize
          WRITE_LEDR: begin
            LEDR <= data_in[9:0];
          end

          WRITE_VGA: begin
            vga_pen_x <= data_in[23:16];
            vga_pen_y <= data_in[15:8];
            vga_pen_color <= data_in[7:0];
            vga_pen_draw <= 1'b1;
          end

          READ_PS2: begin
            ps2_get_key <= addr - 32'h30000008;
          end
				endcase
			end
			
			state <= next_state;
		end
	end

endmodule

module vga_fun(
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

  // 40 x 30
  wire [7:0] x_pixel = (x_counter - 144) >> 4;
  wire [7:0] y_pixel = (y_counter - 33)  >> 4;

  reg slower_clock;

  // pixel framebuffer, reads must be synchronous
  reg [7:0] pixels [0:2047]; // bigger than 40x30, weird so quartus may infer it?
  wire [10:0] pixel_addr = y_pixel * 40 + x_pixel;
  wire [10:0] pixel_write_addr = pen_y * 40 + pen_x;
  reg [7:0] pixel_data;

  always @(posedge clk) begin
    if (pen_x < 40 && pen_y < 30 && pen_draw && rst_n)
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
