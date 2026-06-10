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
  //////////////////////////////////

  wire rst_n;

  rst_n_init rst_n_init(
    .clk(CLOCK_50),
    .rst_n(rst_n)
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


  wire instruction_fetch_request;
  wire [31:0] instruction_fetch_addr;
  wire [31:0] instruction_fetch_result;
  wire instruction_fetch_finished;
  wire instruction_fetch_busy;

  wire [31:0] mem_access_addr;
  wire [31:0] mem_access_data;
  wire mem_access_byte_mode;
  wire mem_access_read_request;
  wire mem_access_write_request;
  wire [31:0] mem_access_result;
  wire mem_access_finished;
  wire mem_access_busy;
  memory_multiplexer memory_multiplexer(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    // instruction fetch
    .instruction_fetch_request(instruction_fetch_request),
    .instruction_fetch_addr(instruction_fetch_addr),

    .instruction_fetch_result(instruction_fetch_result),
    .instruction_fetch_finished(instruction_fetch_finished),
    .instruction_fetch_busy(instruction_fetch_busy),

    // memory read/write
    .mem_access_addr(mem_access_addr),
    .mem_access_data(mem_access_data),
    .mem_access_byte_mode(mem_access_byte_mode),

    .mem_access_read_request(mem_access_read_request),
    .mem_access_write_request(mem_access_write_request),

    .mem_access_result(mem_access_result),
    .mem_access_finished(mem_access_finished),
    .mem_access_busy(mem_access_busy),

    // mem controller interface
    .mem_controller_write_request(memory_write_request),
    .mem_controller_read_request(memory_read_request),
    .mem_controller_byte_mode(memory_byte_mode),
    .mem_controller_addr_in(memory_addr),
    .mem_controller_data_in(memory_data_in),
    .mem_controller_data_out(memory_data_out),
    .mem_controller_busy(memory_busy),
    .mem_controller_finished(memory_finished)
  );

  ////////////// PROCESSOR //////////////

  wire memory_access_stalled;
  wire instruction_fetch_stalled;
  wire processor_stalled;
  stall_manager stall_manager(
    .memory_access_stalled(memory_access_stalled),
    .instruction_fetch_stalled(instruction_fetch_stalled),

    .stall_processor(processor_stalled)
  );

  wire [4:0] rs1_bank_interface_in;
  wire [4:0] rs2_bank_interface_in;
  wire [31:0] rs1_bank_interface_out;
  wire [31:0] rs2_bank_interface_out;
  wire [4:0] rd_writeback_reg;
  wire [31:0] rd_writeback_val;
  reg_bank reg_bank(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .stalled(processor_stalled),

    .rs1_bank_interface_in(rs1_bank_interface_in),
    .rs2_bank_interface_in(rs2_bank_interface_in),
    .rs1_bank_interface_out(rs1_bank_interface_out),
    .rs2_bank_interface_out(rs2_bank_interface_out),
    
    .rd_writeback_reg(rd_writeback_reg),
    .rd_writeback_val(rd_writeback_val)
  );

  wire [31:0] next_pc;
  wire [31:0] pc;
  wire [31:0] instruction32;
  wire ins_valid;
  instruction_fetch_and_pc instruction_fetch_and_pc(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .next_pc(next_pc),
    .pc(pc),

    .instruction32(instruction32),

    .processor_stalled(processor_stalled),
    .issue_stall(instruction_fetch_stalled),
    .ins_valid(ins_valid),

    // memory multiplexer interface
    .instruction_fetch_request(instruction_fetch_request),
    .instruction_fetch_addr(instruction_fetch_addr),

    .instruction_fetch_result(instruction_fetch_result),
    .instruction_fetch_finished(instruction_fetch_finished),
    .instruction_fetch_busy(instruction_fetch_busy)
  );

  wire [5:0] decoder_op;
  wire [4:0] decoder_rd;
  wire [31:0] decoder_rs1;
  wire [31:0] decoder_rs2;
  wire [31:0] decoder_imm;
  decoder decoder(
    .clk(CLOCK_50),
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
    .clk(CLOCK_50),
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

    .op(decoder_op),
    .write_data(decoder_rs1),
    .execute_result(execute_result),
    .read_res(memory_access_result),

    .ins_valid(ins_valid),
    .issue_stall(memory_access_stalled),

    // mem multiplexer interface
    .mem_access_read_request(mem_access_read_request),
    .mem_access_write_request(mem_access_write_request),
    .mem_access_addr(mem_access_addr),
    .mem_access_data(mem_access_data),
    .mem_access_byte_mode(mem_access_byte_mode),

    .mem_access_result(mem_access_result),
    .mem_access_finished(mem_access_finished),
    .mem_access_busy(mem_access_busy)
  );

  reg_writeback reg_writeback(
    .clk(CLOCK_50),
    .rst_n(rst_n),

    .rd_in(decoder_rd),
    .op(decoder_op),
    .execute_result(execute_result),
    .mem_out(memory_access_result),

    .reg_bank_rd(rd_writeback_reg),
    .reg_bank_val(rd_writeback_val)
  );
endmodule