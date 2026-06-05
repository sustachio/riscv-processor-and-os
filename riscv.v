module riscv(
	input CLOCK_50,

	// flash
	output [21:0] FL_ADDR, 
	input [7:0] FL_DQ, 
	output FL_OE_N, // !output enable
	output FL_RST_N, 
	output FL_WE_N, // !write enable
	
	// SRAM
	output [17:0] SRAM_ADDR,
	inout [15:0] SRAM_DQ,
	output SRAM_WE_N, // !write enable
	output SRAM_OE_N, // !output enable
	output SRAM_UB_N, // !upper byte mask
	output SRAM_LB_N, // !lower byte mask
	output SRAM_CE_N, // !chip enable
	
	// I/O
	input [9:0] SW,
	input [3:0] KEY,
	output [9:0] LEDR,
	output [7:0] LEDG,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3
);
  wire rst_n = 1;

  // SW[9] - read (1)/write (0)
  // SW[8] - byte mode enable
  // SW[7] - addr[28] 0 - flash, 1 - sram
  // SW[6:4] - addr[2:0]
  // SW[3:0] - data

  // KEY[0] - run command
  // KEY[1] - press to look at significant two bytes

  // LEDG[7] - busy
  // LEDG[6] - ready
	
  wire look_at_sig;

  wire trigger_request;
  wire read_or_write = SW[9];

  wire read_request  = read_or_write ? trigger_request : 0;
  wire write_request = read_or_write ? 0 : trigger_request;
  wire byte_mode = SW[8];
  wire [31:0] data_in = SW[3:0];
  wire [31:0] addr;
  assign addr[31:29] = 0;
  assign addr[28] = SW[7];
  assign addr[27:3] = 0;
  assign addr[2:0] = SW[6:4];
  wire [31:0] data_out;
	
	wire busy;
	wire finished;
	
	assign LEDG[7] = busy;
	assign LEDG[6] = finished;

	
	button_debounce #(.SINGLE_CYCLE_TRIGGER(1)) sram_command_trigger(
		.clk(CLOCK_50),
		.button(!KEY[0]),
		.debounced(trigger_request)
	);

	button_debounce #(.SINGLE_CYCLE_TRIGGER(0)) num_display_control(
		.clk(CLOCK_50),
		.button(!KEY[1]),
		.debounced(look_at_sig)
	);


	display_32bit_7seg mydisp(
		.num(data_out),
		.hex0(HEX0),
		.hex1(HEX1),
		.hex2(HEX2),
		.hex3(HEX3),
		.upper_sel(look_at_sig)
	);

  memory_controller mem(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .write_request(write_request),
    .read_request(read_request),

    .byte_mode(byte_mode),

    .addr_in(addr),
    .data_in(data_in),
    .data_out(data_out),

    .busy(busy),
    .finished(finished),

    ///////// pins: ///////
    // flash
    .FL_ADDR(FL_ADDR),
    .FL_DQ(FL_DQ),
    .FL_OE_N(FL_OE_N),
    .FL_RST_N(FL_RST_N),
    .FL_WE_N(FL_WE_N),
    
    // SRAM
    .SRAM_ADDR(SRAM_ADDR),
    .SRAM_DQ(SRAM_DQ),
    .SRAM_WE_N(SRAM_WE_N),
    .SRAM_OE_N(SRAM_OE_N),
    .SRAM_UB_N(SRAM_UB_N),
    .SRAM_LB_N(SRAM_LB_N),
    .SRAM_CE_N(SRAM_CE_N)
  );
endmodule