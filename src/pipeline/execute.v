`include "global_constants.vh"

module execute(
  input rst_n,

	input [5:0] op,
	input [4:0] rd,
	input [31:0] rs1,
	input [31:0] rs2,
	input [31:0] imm,
  input [31:0] pc,

  output reg [31:0] res,

  output reg [31:0] next_pc
);
  // signed versions
  wire signed [31:0] rs1_s = $signed(rs1);
  wire signed [31:0] rs2_s = $signed(rs2);
  wire signed [31:0] imm_s = $signed(imm);

  always @(*) begin
    // defaults / !rst_n
		res = 0;
		next_pc = 0;
		
    if (rst_n) begin
      next_pc = pc + 4;

      case (op)
        `OP_LUI:
          res = imm;
        `OP_AUIPC:
          res = pc + imm;
        `OP_ADDI:
          res = rs1 + imm;
        `OP_SLTI:
          res = rs1_s < imm_s;
        `OP_SLTIU:
          res = rs1 < imm;
        `OP_XORI:
          res = rs1 ^ imm;
        `OP_ORI:
          res = rs1 | imm;
        `OP_ANDI:
          res = rs1 & imm;
        `OP_SLLI:
          res = rs1 << imm;
        `OP_SRLI:
          res = rs1 >> imm;
        `OP_SRAI:
          res = rs1 >>> imm;
        `OP_ADD:
          res = rs1 + rs2;
        `OP_SUB:
          res = rs1 - rs2;
        `OP_SLL:
          res = rs1 << rs2[4:0];
        `OP_SLT:
          res = rs1_s < rs2_s;
        `OP_SLTU:
          res = rs1 < rs2;
        `OP_XOR:
          res = rs1 ^ rs2;
        `OP_SRL:
          res = rs1 >> rs2[4:0];
        `OP_SRA:
          res = rs1 >>> rs2[4:0];
        `OP_OR:
          res = rs1 | rs2;
        `OP_AND:
          res = rs1 & rs2;

        // to be sent to memory stage
        // res is address
        `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU, `OP_SB, `OP_SH, `OP_SW:
          res = rs1 + imm;

        // branching instructions
        `OP_JAL: begin
          res = pc + 4;
          next_pc = pc + imm;
        end

        `OP_JALR: begin
          res = pc + 4;
          next_pc = (rs1 + imm) & ~32'd1; // & for 2-byte alignment
        end

        `OP_BEQ: begin
          if (rs1 == rs2)
            next_pc = pc + imm;
        end

        `OP_BNE: begin
          if (rs1 != rs2)
            next_pc = pc + imm;
        end

        `OP_BLT: begin
          if (rs1_s < rs2_s)
            next_pc = pc + imm;
        end

        `OP_BGE: begin
          if (rs1_s >= rs2_s)
            next_pc = pc + imm;
        end

        `OP_BLTU: begin
          if (rs1 < rs2)
            next_pc = pc + imm;
        end

        `OP_BGEU: begin
          if (rs1 >= rs2)
            next_pc = pc + imm;
        end

        `OP_FENCE, `OP_ECALL, `OP_EBREAK, `OP_ILLEGAL:
          res = 32'd0;
					
				default:
					res = 32'd0;
      endcase
    end
  end
endmodule
