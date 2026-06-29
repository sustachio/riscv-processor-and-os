`include "global_constants.vh"

// x0 - constant 0
// x1 - conventional call return address
// x2 - conventional stack pointer
// x5 - conventional alternate link register
module reg_bank(
  input clk,
  input rst_n,

  input [2:0] processor_state,

	input wire [4:0] rs1_bank_interface_in,
	input wire [4:0] rs2_bank_interface_in,
	output reg [31:0] rs1_bank_interface_out,
	output reg [31:0] rs2_bank_interface_out,
	
	input wire [4:0] rd_writeback_reg,
  input wire [31:0] rd_writeback_val,

  input TEST_ALLOW_WB_COMPLETE,
  input [4:0] TEST_REG_IN,
  output reg [31:0] TEST_REG_OUT
);
  // x0 unused
  reg [31:0] registers [0:31];

  // write result
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin : block_name_because_modelsim_is_old
			integer i;
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 0;
      end
    end else begin
      if (rd_writeback_reg != 0 && (processor_state == `WRITEBACK) && TEST_ALLOW_WB_COMPLETE)
        registers[rd_writeback_reg] <= rd_writeback_val;
    end
  end

  // read ports
  always @(*) begin
    if (!rst_n) begin
      rs1_bank_interface_out = 0;
      rs2_bank_interface_out = 0;
    end else begin
      rs1_bank_interface_out = registers[rs1_bank_interface_in];
      rs2_bank_interface_out = registers[rs2_bank_interface_in];
      TEST_REG_OUT = registers[TEST_REG_IN];

      if (rs1_bank_interface_in == 0) rs1_bank_interface_out = 0;
      if (rs2_bank_interface_in == 0) rs2_bank_interface_out = 0;
      if (TEST_REG_IN == 0) TEST_REG_OUT = 0;
    end
  end
endmodule