`include "global_constants.vh"

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
	output [6:0] HEX3,

  // video
  output [3:0] VGA_R,
  output [3:0] VGA_G,
  output [3:0] VGA_B,
  output VGA_HS,
  output VGA_VS,
	
	// PS/2 keyboard
	input PS2_CLK,
	input PS2_DAT
);
  //////////////////////////////////

  wire clk = CLOCK_50;
  wire pll_locked;
  wire rst_n;
  
  /*
  plltest plltest (
    .areset(~rst_n),
    .inclk0(CLOCK_50),
    .c0(clk),
    .locked(pll_locked)
  );*/


  reg TEST_ALLOW_WB_COMPLETE;
  wire [4:0] TEST_REG_IN;
  wire [31:0] TEST_REG_OUT;

  

  rst_n_init rst_n_init(
    .clk(clk),
    .rst_n(rst_n)
  );

  wire [2:0] processor_state;
  wire [1:0] processor_privilege;
  wire [1:0] next_privilege;
  wire [5:0] decoder_op;
  wire mem_mux_finished;
  processor_state_manager processor_state_manager(
    .clk(clk),
    .rst_n(rst_n),

    .mem_finished(mem_mux_finished),
    .decoder_op(decoder_op),
    .next_privilege(next_privilege),

    .processor_state(processor_state),
    .processor_privilege(processor_privilege),

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

  wire [7:0] vga_pen_x;
  wire [7:0] vga_pen_y;
  wire [7:0] vga_pen_color;
  wire vga_pen_draw;

  wire [6:0] ps2_get_key;
  wire ps2_key_pressed;
  memory_controller mem(
    .clk(clk),
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
    .SRAM_CE_N(SRAM_CE_N),

    // memory mapped i/o
    .LEDR(LEDR),

    .vga_pen_x(vga_pen_x),
    .vga_pen_y(vga_pen_y),
    .vga_pen_color(vga_pen_color),
    .vga_pen_draw(vga_pen_draw),

    .ps2_get_key(ps2_get_key),
    .ps2_key_pressed(ps2_key_pressed)
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
    .clk(clk),
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
  instruction_fetch_and_pc instruction_fetch_and_pc(
    .clk(clk),
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

    .TEST_ALLOW_WB_COMPLETE(TEST_ALLOW_WB_COMPLETE)
  );

  wire [4:0] decoder_rd;
  wire [31:0] decoder_rs1;
  wire [31:0] decoder_rs2;
  wire [31:0] decoder_imm;
  wire [11:0] decoder_csr_i;
  decoder decoder(
    .rst_n(rst_n),

    .instruction32(instruction32),
    .op(decoder_op),
    .rd(decoder_rd),
    .rs1(decoder_rs1),
    .rs2(decoder_rs2),
    .imm(decoder_imm),
    .csr_i(decoder_csr_i),
    
    .rs1_bank_interface_in(rs1_bank_interface_in),
    .rs2_bank_interface_in(rs2_bank_interface_in),
    .rs1_bank_interface_out(rs1_bank_interface_out),
    .rs2_bank_interface_out(rs2_bank_interface_out)
  );

  wire [31:0] csr_read;
  wire illegal_csr_access;

  wire timer_irq = 0;
  wire external_irq = 0;

  wire [63:0] mstatus;
  wire [31:0] mtvec;
  wire [31:0] mcause;
  wire [31:0] mtval;
  wire [31:0] mepc;
  wire [31:0] mie;
  wire [31:0] mip;
  wire [31:0] mscratch;

  wire [63:0] next_mstatus;
  wire [31:0] next_mtvec;
  wire [31:0] next_mcause;
  wire [31:0] next_mtval;
  wire [31:0] next_mepc;

  wire [31:0] TEST_PROBE_NEW_CSR_VAL;
  control_status_registers control_status_registers(
    .clk(clk),
    .rst_n(rst_n),

    .processor_state(processor_state),
    .processor_privilege(processor_privilege),
    .TEST_ALLOW_WB_COMPLETE(TEST_ALLOW_WB_COMPLETE),

    .timer_irq(timer_irq),
    .external_irq(external_irq),

    .op(decoder_op),
    .imm(decoder_imm),
    .rs1_val(decoder_rs1),
    .csr_i(decoder_csr_i), // only valid on csr instructions

    .csr_read(csr_read),

    // direct outputs
    .mstatus(mstatus),
    .mtvec(mtvec),
    .mcause(mcause),
    .mtval(mtval),
    .mepc(mepc),
    .mie(mie),
    .mip(mip),
    .mscratch(mscratch),

    // set by trap handler
    .next_mstatus(next_mstatus),
    .next_mtvec(next_mtvec),
    .next_mcause(next_mcause),
    .next_mtval(next_mtval),
    .next_mepc(next_mepc),

    .illegal_csr_access(illegal_csr_access),
    .TEST_PROBE_NEW_CSR_VAL(TEST_PROBE_NEW_CSR_VAL)
  );

	wire [31:0] execute_next_pc;
  trap_manager trap_manager(
    .clk(clk),
    .rst_n(rst_n),

    .pc(pc),
    .execute_next_pc(execute_next_pc),
    .next_pc(next_pc),

    .op(decoder_op),

    .illegal_csr_access(illegal_csr_access),

    .processor_state(processor_state),
    .processor_privilege(processor_privilege),
    .next_privilege(next_privilege),

    .mstatus(mstatus),
    .mtvec(mtvec),
    .mcause(mcause),
    .mtval(mtval),
    .mepc(mepc),
    .mip(mip),
    .mie(mie),

    .next_mstatus(next_mstatus),
    .next_mtvec(next_mtvec),
    .next_mcause(next_mcause),
    .next_mtval(next_mtval),
    .next_mepc(next_mepc)
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

    .csr_read(csr_read),

    .res(execute_result),

    .next_pc(execute_next_pc)
  );

  wire [31:0] memory_access_result;
  memory_access memory_access(
    .clk(clk),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .op(decoder_op),
    .write_data(decoder_rs2),
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
    .clk(clk),
    .rst_n(rst_n),

    .processor_state(processor_state),

    .rd_in(decoder_rd),
    .op(decoder_op),
    .execute_result(execute_result),
    .mem_out(memory_access_result),

    .reg_bank_rd(rd_writeback_reg),
    .reg_bank_val(rd_writeback_val)
  );


  /////////// HARDWARE INTERFACES /////////
  vga_interface vga_interface(
    .rst_n(rst_n),
    .clk(clk),

    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
		.pen_x(vga_pen_x),
		.pen_y(vga_pen_y),
		.pen_color(vga_pen_color),
		.pen_draw(vga_pen_draw)
  );

  ps2_interface ps2_interface(
    .rst_n(rst_n),
    .clk(clk),

    .get_key(ps2_get_key),
    .key_pressed(ps2_key_pressed),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT)
  );

  //////// DEBUGING ///////////

  // SW[9:6] - select hex display (see below)
  // SW[5]   - step mode
  // SW[4:0] - TEST_REG_IN address

  // KEY[0] - allow WB (step)
  // KEY[1] - press to look at significant two bytes
  // KEY[2] - hold for debug mode (allow EBREAKs)

  // LEDG[7:0] - TEST_REG_OUT[7:0] 

  // hex - selected by SW[9:6]
  // 0000 - decoder_op
  // 0001 - TEST_REG_OUT
  // 0010 - processor_state
  // 0011 - mem_mux_finished
  // 0100 - rs1 in (addr)
  // 0101 - rs2 in (addr)
  // 0110 - rs1 out (value)
  // 0111 - rs2 out (value)
  // 1000 - rd addr in
  // 1001 - rd value in
  // 1010 - pc
  // 1011 - next_pc
  // 1100 - instruction32
  // 1101 - decoder_imm
  // 1110 - execute_result

  reg [31:0] hex_num;
  always @(*) begin
    if (KEY[3]) begin
      case (SW[9:6])
        4'b0000: hex_num = decoder_op;
        4'b0001: hex_num = TEST_REG_OUT;
        4'b0010: hex_num = processor_state;
        4'b0011: hex_num = mem_mux_finished;
        4'b0100: hex_num = rs1_bank_interface_in;
        4'b0101: hex_num = rs2_bank_interface_in;
        4'b0110: hex_num = rs1_bank_interface_out;
        4'b0111: hex_num = rs2_bank_interface_out;
        4'b1000: hex_num = rd_writeback_reg;
        4'b1001: hex_num = rd_writeback_val;
        4'b1010: hex_num = pc;
        4'b1011: hex_num = next_pc;
        4'b1100: hex_num = instruction32;
        4'b1101: hex_num = decoder_imm;
        4'b1110: hex_num = execute_result;

        default: hex_num = 0;
      endcase
    end else begin
      case (SW[9:6])
        4'b0000: hex_num = decoder_csr_i;
        4'b0001: hex_num = processor_privilege;
        4'b0010: hex_num = next_privilege;
        4'b0011: hex_num = illegal_csr_access;
        4'b0100: hex_num = memory_data_out;
        4'b0101: hex_num = memory_data_in;
        4'b0110: hex_num = memory_addr;

        default: hex_num = 0;
      endcase
    end
  end
	
  wire hex_upp_sel;

  assign TEST_REG_IN = SW[4:0];
	
	assign LEDG = {ps2_get_key, ps2_key_pressed};
	
  wire step;
  always @(*) begin
    TEST_ALLOW_WB_COMPLETE = (SW[5] && ((decoder_op != `OP_EBREAK) || ~SW[2])) || step;
  end
	button_debounce #(.PRECISE_CYCLE_TRIGGER(1)) sram_command_trigger(
		.clk(clk),
		.button(!KEY[0]),
		.debounced(step)
	);

	button_debounce #(.PRECISE_CYCLE_TRIGGER(0)) num_display_control(
		.clk(clk),
		.button(!KEY[1]),
		.debounced(hex_upp_sel)
	);

	display_32bit_7seg mydisp(
		.num(hex_num),
		.hex0(HEX0),
		.hex1(HEX1),
		.hex2(HEX2),
		.hex3(HEX3),
		.upper_sel(hex_upp_sel)
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