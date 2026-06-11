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
	assign LEDG = 0;

  //////////////////////////////////

  wire TEST_ALLOW_WB_COMPLETE;
  wire [4:0] TEST_REG_IN;
  wire [31:0] TEST_REG_OUT;

  wire rst_n;

  rst_n_init rst_n_init(
    .clk(CLOCK_50),
    .rst_n(rst_n)
  );

  wire [2:0] processor_state;
  wire [5:0] decoder_op;
  wire mem_mux_finished;
  processor_state_manager processor_state_manager(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .mem_finished(mem_mux_finished),
    .decoder_op(decoder_op),

    .processor_state(processor_state),

    .TEST_ALLOW_WB_COMPLETE(TEST_ALLOW_WB_COMPLETE)
  );

  /////////////// MEMORY /////////////

  wire memory_write_request;
  wire memory_read_request;

  wire memory_byte_mode;

  wire [31:0] memory_addr;
  wire [31:0] memory_data_in;
  wire [31:0] memory_data_out;

  wire memory_busy;
  wire memory_finished;
  memory_controller mem(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .write_request(memory_write_request),
    .read_request(memory_read_request),

    .byte_mode(memory_byte_mode),

    .addr_in(memory_addr),
    .data_in(memory_data_in),
    .data_out(memory_data_out),

    .busy(memory_busy),
    .finished(memory_finished),

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

  wire fetch_read_request;
  wire [31:0] fetch_addr;
  wire [31:0] fetch_result;

  wire mem_access_read_request;
  wire mem_access_write_request;
  wire [31:0] mem_access_addr;
  wire [31:0] mem_access_data_in;
  wire mem_access_byte_mode;
  wire [31:0] mem_access_data_out;
	memory_multiplexer memory_multiplexer(
    .rst_n(rst_n),

    .processor_state(processor_state),

    .fetch_read_request(fetch_read_request),
    .fetch_addr(fetch_addr),
    .fetch_result(fetch_result),

    .mem_access_read_request(mem_access_read_request),
    .mem_access_write_request(mem_access_write_request),
    .mem_access_addr(mem_access_addr),
    .mem_access_data_in(mem_access_data_in),
    .mem_access_byte_mode(mem_access_byte_mode),
    .mem_access_data_out(mem_access_data_out),

    .finished(mem_mux_finished),

    // memory_controller interface
    .memory_read_request(memory_read_request),
    .memory_write_request(memory_write_request),
    .memory_byte_mode(memory_byte_mode),
    .memory_addr(memory_addr),
    .memory_data_in(memory_data_in),
    .memory_data_out(memory_data_out),
    .memory_finished(memory_finished)
  );

  ////////////// PROCESSOR //////////////

  wire [4:0] rs1_bank_interface_in;
  wire [4:0] rs2_bank_interface_in;
  wire [31:0] rs1_bank_interface_out;
  wire [31:0] rs2_bank_interface_out;
  wire [4:0] rd_writeback_reg;
  wire [31:0] rd_writeback_val;
  reg_bank reg_bank(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .rs1_bank_interface_in(rs1_bank_interface_in),
    .rs2_bank_interface_in(rs2_bank_interface_in),
    .rs1_bank_interface_out(rs1_bank_interface_out),
    .rs2_bank_interface_out(rs2_bank_interface_out),
    
    .rd_writeback_reg(rd_writeback_reg),
    .rd_writeback_val(rd_writeback_val),

    .TEST_ALLOW_WB_COMPLETE(TEST_ALLOW_WB_COMPLETE),
    .TEST_REG_IN(TEST_REG_IN),
    .TEST_REG_OUT(TEST_REG_OUT)
  );

  wire [31:0] next_pc;
  wire [31:0] pc;
  wire [31:0] instruction32;
  wire ins_valid;
  instruction_fetch_and_pc instruction_fetch_and_pc(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .next_pc(next_pc),
    .pc(pc),

    .instruction32(instruction32),

    // memory multiplexer interface
    .mem_read_request(fetch_read_request),
    .mem_addr(fetch_addr),
    .mem_read_result(fetch_result),
    .mem_finished(mem_mux_finished),

    .TEST_ALLOW_WB_COMPLETE(TEST_ALLOW_WB_COMPLETE),
  );

  wire [4:0] decoder_rd;
  wire [31:0] decoder_rs1;
  wire [31:0] decoder_rs2;
  wire [31:0] decoder_imm;
  decoder decoder(
    .rst_n(rst_n),

    .instruction32(instruction32),
    .op(decoder_op),
    .rd(decoder_rd),
    .rs1(decoder_rs1),
    .rs2(decoder_rs2),
    .imm(decoder_imm),
    
    .rs1_bank_interface_in(rs1_bank_interface_in),
    .rs2_bank_interface_in(rs2_bank_interface_in),
    .rs1_bank_interface_out(rs1_bank_interface_out),
    .rs2_bank_interface_out(rs2_bank_interface_out)
  );

  wire [31:0] execute_result;
  execute execute(
    .rst_n(rst_n),

    .op(decoder_op),
    .rd(decoder_rd),
    .rs1(decoder_rs1),
    .rs2(decoder_rs2),
    .imm(decoder_imm),
    .pc(pc),

    .res(execute_result),

    .next_pc(next_pc)
  );

  wire [31:0] memory_access_result;
  memory_access memory_access(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .op(decoder_op),
    .write_data(decoder_rs1),
    .execute_result(execute_result),
    .read_res(memory_access_result),

    // mem multiplexer interface
    .mem_access_read_request(mem_access_read_request),
    .mem_access_write_request(mem_access_write_request),
    .mem_access_addr(mem_access_addr),
    .mem_access_data(mem_access_data_in),
    .mem_access_byte_mode(mem_access_byte_mode),

    .mem_access_result(mem_access_data_out),
    .mem_access_finished(mem_mux_finished)
  );

  reg_writeback reg_writeback(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .rd_in(decoder_rd),
    .op(decoder_op),
    .execute_result(execute_result),
    .mem_out(memory_access_result),

    .reg_bank_rd(rd_writeback_reg),
    .reg_bank_val(rd_writeback_val)
  );
  

  //////// DEBUGING ///////////

  // SW[4:0] - test reg address

  // KEY[0] - allow WB
  // KEY[1] - press to look at significant two bytes

  // LEDR[9:0] - test reg out[9:0]

  // hex - decoder_op
	
  wire look_at_sig;

  assign TEST_REG_IN = SW[4:0];
	
	assign LEDR = TEST_REG_OUT[9:0];
	
	button_debounce #(.PRECISE_CYCLE_TRIGGER(1)) sram_command_trigger(
		.clk(CLOCK_50),
		.button(!KEY[0]),
		.debounced(TEST_ALLOW_WB_COMPLETE)
	);

	button_debounce #(.PRECISE_CYCLE_TRIGGER(0)) num_display_control(
		.clk(CLOCK_50),
		.button(!KEY[1]),
		.debounced(look_at_sig)
	);

	display_32bit_7seg mydisp(
		.num(decoder_op),
		.hex0(HEX0),
		.hex1(HEX1),
		.hex2(HEX2),
		.hex3(HEX3),
		.upper_sel(look_at_sig)
	);

endmodule


// night sky https://www.asciiart.eu/ascii-night-sky-generator
/*
     o                 '   .         o                      +              .    
                 .           .                              .                   
 +                      +                                                 *     
                                      o           .         _|_     '     o     
            |               '                                |          '       
  .      /- o -                                                    .            
   '    /   |        .  |              '                   . +         .        
       *             ' -o-           +        '                 o .             
     .                  |                       +    .                .        .
         .                                                             .        
               .           .  .                                     .     +     
                    . .                 '                  .       .            
                     o                  '      ':.          _..               . 
                     o                        .  '::._    '`-. `.               
         ' .  .'                            .      '._)*      \  \              
  .  +                      +           +              .      |  |              
                                                              /  /              
*.   .        .     *      .    o                         _.-`_.`               
         '          '   ' +~~  .           +               '''                  
                                           +         .        '        +        
*/