// mappings:
// Flash (4MB) ROM  0x00000000-0x003FFFFF
// SRAM  (512KB)    0x10000000-0x1007FFFF
// SDRAM (8MB)      0x20000000-0x207FFFFF

// manage requests from both instruction fetch and memory access
module memory_multiplexer(
  input clk,
  input rst_n,

  // instruction fetch
  input instruction_fetch_request,
  input [31:0] instruction_fetch_addr,

  output reg [31:0] instruction_fetch_result,
  output reg instruction_fetch_finished,
  output reg instruction_fetch_busy, // used to check if access started

  // memory read/write
  input [31:0] mem_access_addr,
  input [31:0] mem_access_data,
  input mem_access_byte_mode,

  input mem_access_read_request,
  input mem_access_write_request,

  output reg [31:0] mem_access_result,
  output reg mem_access_finished,
  output reg mem_access_busy, // used to check if access started

  // mem controller interface
  output reg mem_controller_write_request,
  output reg mem_controller_read_request,
  output reg mem_controller_byte_mode,
  output reg [31:0] mem_controller_addr_in,
  output reg [31:0] mem_controller_data_in,
  input  [31:0] mem_controller_data_out,
  input  mem_controller_busy,
  input  mem_controller_finished
);
  // states
  localparam IDLE = 0;
  localparam INS_FETCH = 1;
  localparam MEM_READ = 2;
  localparam MEM_WRITE = 3;

  reg [1:0] state = IDLE;
  reg [1:0] next_state = IDLE;

  always @(posedge clk or negedge rst_n) begin
    state = next_state;
    if (!rst_n)
      state = IDLE;
  end

  always @(posedge mem_controller_finished or 
           posedge mem_controller_busy or
           negedge rst_n) begin
    if (!rst_n) begin
      instruction_fetch_result <= 0;
      instruction_fetch_finished <= 0;
      instruction_fetch_busy <= 0;
    end 

    // start operation
    else if (mem_controller_busy) begin
      if (state == INS_FETCH) begin
        instruction_fetch_result <= 0;
        instruction_fetch_finished <= 0;
        instruction_fetch_busy <= 1;
      end

      else if (state == MEM_READ || state == MEM_WRITE) begin
        mem_access_result <= 0;
        mem_access_finished <= 0;
        mem_access_busy <= 1;
      end
    end

    // finish operation
    else if (mem_controller_finished) begin
      if (state == INS_FETCH) begin
        instruction_fetch_result <= mem_controller_data_out;
        instruction_fetch_finished <= 1;
        instruction_fetch_busy <= 0;
      end

      else if (state == MEM_READ) begin
        mem_access_result <= mem_controller_data_out;
        mem_access_finished <= 1;
        mem_access_busy <= 0;
      end

      else if (state == MEM_WRITE) begin
        mem_access_result <= 0;
        mem_access_finished <= 1;
        mem_access_busy <= 0;
      end
    end
  end

  always @(*) begin
    // defaults / rst_n
    next_state = IDLE;

    mem_controller_write_request = 0;
    mem_controller_read_request = 0;
    mem_controller_byte_mode = 0;
    mem_controller_addr_in = 0;
    mem_controller_data_in = 0;

    if (rst_n) begin
      // instruction fetches take priority
      if (instruction_fetch_request || state == INS_FETCH) begin
        next_state = INS_FETCH;

        mem_controller_write_request = 0;
        mem_controller_read_request = 1;
        mem_controller_byte_mode = 0;
        mem_controller_addr_in = instruction_fetch_addr;
        mem_controller_data_in = 0;
      end 

      // mem read
      if (mem_access_read_request || state == MEM_READ) begin
        next_state = MEM_READ;

        mem_controller_write_request = 0;
        mem_controller_read_request = 1;
        mem_controller_byte_mode = mem_access_byte_mode;
        mem_controller_addr_in = mem_access_addr;
        mem_controller_data_in = 0;
      end

      // mem write
      if (mem_access_write_request || state == MEM_WRITE) begin
        next_state = MEM_WRITE;

        mem_controller_write_request = 1;
        mem_controller_read_request = 0;
        mem_controller_byte_mode = mem_access_byte_mode;
        mem_controller_addr_in = mem_access_addr;
        mem_controller_data_in = mem_access_data;
      end

      if (mem_controller_finished)
        next_state = IDLE;
    end
  end
endmodule

module memory_controller(
  input clk,
  input rst_n,

  input write_request,
  input read_request,

  input byte_mode,

  input  [31:0] addr_in,
  input  [31:0] data_in,
  output reg [31:0] data_out,

  output reg busy,
  output reg finished,

  ///////// pins: ///////
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
	output SRAM_CE_N  // !chip enable
);
	////////////////////////////// 4MB 8-bit flash (ROM) @ 0x00000000 /////////////////////
	assign FL_OE_N = 0;
	assign FL_RST_N = 1;
	assign FL_WE_N = 1;

	reg flash_read_request;
	wire [21:0] flash_addr;
	wire [31:0] flash_data;
	wire flash_finished;
  wire flash_busy;
	wire flash_byte_mode;
	
	flash_interface32bit flash32(
		.clk(clk),
		.rst_n(rst_n),

		.interface_addr(FL_ADDR),
		.interface_data(FL_DQ),

		.byte_mode(flash_byte_mode),

		.read_request(flash_read_request),
		.addr(flash_addr),

		.data(flash_data),
		.finished(flash_data_ready),
    .busy(flash_busy)
	);
	
	/////////////////////////////// 512KB 16-bit async SRAM @ 0x10000000 /////////////////////
	assign SRAM_CE_N = 0;
	
	reg sram_read_request;
	reg sram_write_request;
	wire [18:0] sram_addr;
	wire [31:0] sram_data_in;
	wire [31:0] sram_data_out;
	wire sram_finished;
	wire sram_busy;
	wire sram_byte_mode;
	
	sram_interface32bit sram32(
		.clk(clk),
		.rst_n(rst_n),
		
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
		.finished(sram_finished),
		.busy(sram_busy)
	);

  ////////////////////////// 8MB 16-bit SDRAM @ 0x20000000 ////////////////
  // todo

  ////////////////////////// L1 cache /////////////////////
  // todo

  ///////////////////////// Memory Controller //////////////////
  assign flash_addr = addr_in[21:0];
  assign flash_byte_mode = byte_mode;

  assign sram_addr      = addr_in[18:0];
  assign sram_data_in   = data_in;
  assign sram_byte_mode = byte_mode;

  // fsm for tracking which is finishing
  localparam FLASH = 0;
  localparam SRAM = 1;

  reg [1:0] last_module = FLASH;
  reg [1:0] next_module = FLASH;

  always @(*) begin
    flash_read_request = 0;
    sram_read_request  = 0;
    sram_write_request = 0;

    if (!rst_n) begin
      next_module = FLASH;
      finished = 0;
			data_out = 0;
			busy = 0;
    end else begin
      next_module = last_module;

      if (last_module == FLASH) begin
        data_out = flash_data;
        busy = flash_busy;
        finished = flash_finished;
      end

      else if (last_module == SRAM) begin
        data_out = sram_data_out;
        busy = sram_busy;
        finished = sram_finished;
      end

      /////////// read/write requests ///////
      // flash
      if (addr_in[31:28] == 0 && read_request) begin
        flash_read_request = 1;

        next_module = FLASH;
      end

      // sram
      else if (addr_in[31:28] == 1 && read_request) begin
        sram_read_request  = 1;

        next_module = SRAM;
      end

      else if (addr_in[31:28] == 1 && write_request) begin
        sram_write_request  = 1;

        next_module = SRAM;
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      last_module = FLASH;
    else
      last_module = next_module;
  end
endmodule