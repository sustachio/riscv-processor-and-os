module TB_button_debounce();
endmodule

/*
/////////////////////////////// SRAM /////////////////////
	assign SRAM_CE_N = 0;
	
	wire sram_read_request;
	wire sram_write_request;
	wire [17:0] sram_addr;
	wire [31:0] sram_data_in;
	wire [31:0] sram_data_out;
	wire sram_data_ready;
	wire sram_busy;
	wire sram_byte_mode;

  // SW[9] - read (1)/write (0)
  // SW[8] - byte mode enable
  // SW[7:4] - addr
  // SW[3:0] - data

  // KEY[0] - run command
  // KEY[1] - press to look at significant two bytes

  // LEDG[7] - busy
  // LEDG[6] - ready
	
	// LEDR[3:0] - state
	
  wire look_at_sig;

  wire trigger_request;
  wire read_or_write = SW[9];

  assign sram_read_request  = read_or_write ? trigger_request : 0;
  assign sram_write_request = read_or_write ? 0 : trigger_request;
  assign sram_byte_mode = SW[8];
  assign sram_data_in = SW[3:0];
  assign sram_addr = SW[7:4];
	
	assign LEDG[7] = sram_busy;
	assign LEDG[6] = sram_data_ready;

	
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

	sram_interface32bit sram32(
		.clk(CLOCK_50),
		.rst_n(1),
		
		.interface_addr(SRAM_ADDR),
		.interface_data(SRAM_DQ),
    .interface_upper_byte_mask_n(SRAM_UB_N),
    .interface_lower_byte_mask_n(SRAM_LB_N),
		
		.interface_output_enable_n(SRAM_OE_N),
		.interface_write_enable_n(SRAM_WE_N),
		
		.byte_mode(sram_byte_mode),
		
		.read_request(sram_read_request),
		.addr(sram_addr),
		
		.write_request(sram_write_request),
		.write_data(sram_data_in),
		
		.data_out(sram_data_out),
		.finished(sram_data_ready),
		
		.busy(sram_busy),
		
		.TEST_EXPOSE_STATE(LEDR[3:0])
	);
		
	display_32bit_7seg mydisp(
		.num(sram_data_out),
		.hex0(HEX0),
		.hex1(HEX1),
		.hex2(HEX2),
		.hex3(HEX3),
		.upper_sel(look_at_sig)
	);
*/
