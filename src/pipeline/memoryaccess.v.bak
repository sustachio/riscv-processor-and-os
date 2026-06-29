`include "global_constants.vh"

module memory_multiplexer(
  input rst_n,

  input [2:0] processor_state,

  input fetch_read_request,
  input [31:0] fetch_addr,
  output reg [31:0] fetch_result,

  input mem_access_read_request,
  input mem_access_write_request,
  input [31:0] mem_access_addr,
  input [31:0] mem_access_data_in,
  input mem_access_byte_mode,
  output reg [31:0] mem_access_data_out,

  output reg finished,

  // memory_controller interface
  output reg memory_read_request,
  output reg memory_write_request,
  output reg memory_byte_mode,
  output reg [31:0] memory_addr,
  output reg [31:0] memory_data_in,
  input [31:0] memory_data_out,
  input memory_finished
);
  always @(*) begin
    if (!rst_n) begin
      memory_read_request = 0;
      memory_write_request = 0;
      memory_addr = 0;
      memory_data_in = 0;
      memory_byte_mode = 0;

      fetch_result = 0;
      mem_access_data_out = 0;
      finished = 0;
    end else begin
      finished = memory_finished;

      case (processor_state)
        `START_FETCH, `FETCH: begin
          memory_read_request = fetch_read_request;
          memory_write_request = 0;
          memory_addr = fetch_addr;
          memory_data_in = 0;
          memory_byte_mode = 0;

          fetch_result = memory_data_out;
          mem_access_data_out = 0;
        end

        `START_MEM, `MEM_ACCESS: begin
          memory_read_request = mem_access_read_request;
          memory_write_request = mem_access_write_request;
          memory_addr = mem_access_addr;
          memory_data_in = mem_access_data_in;
          memory_byte_mode = mem_access_byte_mode;

          fetch_result = 0;
          mem_access_data_out = memory_data_out;
        end

        default: begin
          memory_read_request = 0;
          memory_write_request = 0;
          memory_addr = 0;
          memory_data_in = 0;

          fetch_result = 0;
          mem_access_data_out = 0;
          finished = 0;
        end
      endcase
    end
  end
endmodule

module memory_access(
  input clk,
  input rst_n,

  input [2:0] processor_state,

  input [5:0]  op,
  input [31:0] write_data,
  input [31:0] execute_result,
  output reg [31:0] read_res,

  // mem multiplexer interface
  output reg mem_access_read_request,
  output reg mem_access_write_request,
  output reg [31:0] mem_access_addr,
  output reg [31:0] mem_access_data,
  output reg mem_access_byte_mode,

  input [31:0] mem_access_result,
  input mem_access_finished,
  input mem_access_busy // used to check if access started
);
  // TODO: make load half and load byte not do the same thing
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_res <= 0;
    end else if (processor_state == `MEM_ACCESS && mem_access_finished) begin
      read_res <= mem_access_result;
    end else begin
      read_res <= read_res; // can i do this? note to future self
    end
  end

  always @(*) begin
    // defaults / rst_n
    mem_access_read_request = 0;
    mem_access_write_request = 0;
    mem_access_addr = 0;
    mem_access_data = 0;
    mem_access_byte_mode = 0;

    if (rst_n) begin
      // requests only for one cycle
      if (processor_state == `START_MEM) begin
        case (op)
          // load word
          // load byte/half INCORRECT
          `OP_LW, `OP_LB, `OP_LH, `OP_LBU, `OP_LHU: begin
            mem_access_read_request = 1;
            mem_access_write_request = 0;
          end

          // store word
          // store byte/half INCORRECT
          `OP_SW, `OP_SB, `OP_SH: begin
            mem_access_read_request = 0;
            mem_access_write_request = 1;
          end
					
					default: begin end // already assigned above
        endcase
      end

      if (processor_state == `START_MEM || processor_state == `MEM_ACCESS) begin
        case (op)
          // load word/load byte (need extra byte_mode)
          `OP_LW, `OP_LH, `OP_LHU: begin
            mem_access_addr = execute_result;
            mem_access_data = 0;
            mem_access_byte_mode = 0;
          end

          // load byte
          `OP_LB, `OP_LBU: begin
            mem_access_addr = execute_result;
            mem_access_data = 0;
            mem_access_byte_mode = 1;
          end

          // store word/store half
          // store half is very incorrect
          `OP_SW, `OP_SH: begin
            mem_access_addr = execute_result;
            mem_access_data = write_data;
            mem_access_byte_mode = 0;
          end
          // store byte
          `OP_SB: begin
            mem_access_addr = execute_result;
            mem_access_data = write_data; // otherwise gets fried in my lazy endienness conversion
            mem_access_byte_mode = 1;
          end
					
					default: begin end // already assigned above
        endcase
      end
    end
  end
endmodule
