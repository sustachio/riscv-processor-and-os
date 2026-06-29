`include "global_constants.vh"

module reg_writeback(
  input clk,
  input rst_n,

  input [2:0] processor_state,

  input wire [4:0]  rd_in,
  input wire [5:0]  op,
  input wire [31:0] execute_result,
  input wire [31:0] mem_out,

  output reg [4:0]  reg_bank_rd,
  output reg [31:0] reg_bank_val
);
  always @(*) begin
    if (!rst_n) begin
      reg_bank_rd = 0;
      reg_bank_val = 0;
    end else begin
      case (op)
        // normal execute instructions
        `OP_LUI, `OP_AUIPC, `OP_ADDI, `OP_SLTI, `OP_SLTIU, `OP_XORI, `OP_ORI, `OP_ANDI, `OP_JALR, `OP_SLLI, `OP_SRLI, `OP_SRAI, `OP_ADD, `OP_SUB, `OP_SLL, `OP_SLT, `OP_SLTU, `OP_XOR, `OP_SRL, `OP_SRA, `OP_OR, `OP_AND, `OP_JAL: begin
          reg_bank_rd = rd_in;
          reg_bank_val = execute_result;
        end

        // signed, must sext
        `OP_LB: begin
          reg_bank_rd = rd_in;
          reg_bank_val = { {24{mem_out[7]}}, mem_out[7:0]};
        end

        // signed, must sext
        `OP_LH: begin
          reg_bank_rd = rd_in;
          reg_bank_val = { {16{mem_out[15]}}, mem_out[15:0]};
        end

        `OP_LW: begin
          reg_bank_rd = rd_in;
          reg_bank_val = mem_out;
        end

        `OP_LBU: begin
          reg_bank_rd = rd_in;
          reg_bank_val = { {24{1'b0}}, mem_out[7:0]};
        end

        `OP_LHU: begin
          reg_bank_rd = rd_in;
          reg_bank_val = { {16{1'b0}}, mem_out[15:0]};
        end

        // branches, ecalls, etc.
        default: begin
          reg_bank_rd = 0;
          reg_bank_val = 0;
        end
      endcase
    end
  end
endmodule