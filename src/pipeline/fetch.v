`include "global_constants.vh"

// NPC (next program counter) calculated in execute
// structured similarly to memory_access
module instruction_fetch_and_pc(
  input clk,
  input rst_n,

  input [2:0] processor_state,

  input [31:0] next_pc,
  output reg [31:0] pc,

  output reg [31:0] instruction32,

  // memory multiplexer interface
  output reg mem_read_request,
  output reg [31:0] mem_addr,

  input [31:0] mem_read_result,
  input mem_finished,

  input TEST_ALLOW_WB_COMPLETE
);
  reg [31:0] saved_instruction32 = 0; // used so ins32 can be used on cycle it is ready

  // memory_mux control
  always @(*) begin
    if (!rst_n) begin
      mem_read_request = 0;
      mem_addr = 0;

      instruction32 = 0;
    end else begin
      case (processor_state)
				`START_FETCH: begin
					mem_read_request = 1;
					mem_addr = pc;
					instruction32 = 0;
				end

				`FETCH: begin
					mem_read_request = 0;
					mem_addr = pc;

					if (mem_finished)
						instruction32 = mem_read_result;
					else
						instruction32 = 0;
				end

				`START_MEM, `MEM_ACCESS, `WRITEBACK: begin
					mem_read_request = 0;
					mem_addr = 0;
					instruction32 = saved_instruction32;
				end

				default: begin
					mem_read_request = 0;
					mem_addr = 0;
					instruction32 = 0;
				end
			endcase
		end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 0;
      saved_instruction32 <= 0;
    end else if (processor_state == `FETCH && mem_finished) begin
      pc <= pc; // can i do this? note to future self
      saved_instruction32 <= mem_read_result;
    end else if (processor_state == `WRITEBACK && TEST_ALLOW_WB_COMPLETE) begin
      pc <= next_pc;
      saved_instruction32 <= 0;
    end 
  end
endmodule
