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