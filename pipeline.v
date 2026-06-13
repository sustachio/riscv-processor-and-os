`include "global_constants.vh"

module processor_state_manager(
  input clk,
  input rst_n,

  input mem_finished,
  input [5:0] decoder_op,

  output reg [2:0] processor_state,

  input TEST_ALLOW_WB_COMPLETE
);
  reg [2:0] next_state;

  always @(*) begin
    case (processor_state)
      `START_FETCH:
        next_state = `FETCH;

      `FETCH: begin
        if (mem_finished) begin
          case (decoder_op)
            `OP_LW, `OP_LB, `OP_LH, `OP_LBU, `OP_LHU, `OP_SW, `OP_SB, `OP_SH:
              next_state = `START_MEM;
            default:
              next_state = `WRITEBACK;
          endcase
        end
        else
          next_state = `FETCH;
      end

      `START_MEM:
        next_state = `MEM_ACCESS;

      `MEM_ACCESS: begin
        if (mem_finished) begin
          next_state = `WRITEBACK;
        end
        else 
          next_state = `MEM_ACCESS;
      end

      `WRITEBACK: begin
        if (TEST_ALLOW_WB_COMPLETE)
          next_state = `START_FETCH;
        else
          next_state = `WRITEBACK;
      end
				
			default: // to make the compiler happy
				next_state = `START_FETCH;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      processor_state <= `START_FETCH;
    else begin
      processor_state <= next_state; 
    end
  end

endmodule

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

module decoder(
	input rst_n,

	input [31:0] instruction32,
	output reg [5:0] op,
	output reg [4:0] rd,
	output reg [31:0] rs1,
	output reg [31:0] rs2,
	output reg [31:0] imm,
	
	output wire [4:0] rs1_bank_interface_in,
	output wire [4:0] rs2_bank_interface_in,
	input wire [31:0] rs1_bank_interface_out,
	input wire [31:0] rs2_bank_interface_out
);
  assign rs1_bank_interface_in = instruction32[19:15];
  assign rs2_bank_interface_in = instruction32[24:20];

  //wire [6:0] opcode = instruction32[6:0];
  //wire [6:0] func7  = instruction32[31:25];
  //wire [2:0] func3  = instruction32[14:12];

  always @(*)
    if (!rst_n) begin
      // nop
      op = `OP_ADDI;
      rs1 = 0;
      rs2 = 0;
      imm = 0;
      rd = 0;
    end
  else begin
    rd = instruction32[11:7];
    rs1 = rs1_bank_interface_out;
    rs2 = rs2_bank_interface_out;

    casez (instruction32)
      // U-Type
      //  imm[31:12]           rd    op
      32'b????????????????????_?????_0110111: op = `OP_LUI;
      32'b????????????????????_?????_0010111: op = `OP_AUIPC;

      // I-Type
      //  imm[11:0]    rs1   func3 rd    op
      32'b????????????_?????_000___?????_0010011: op = `OP_ADDI;
      32'b????????????_?????_010___?????_0010011: op = `OP_SLTI;
      32'b????????????_?????_011___?????_0010011: op = `OP_SLTIU;
      32'b????????????_?????_100___?????_0010011: op = `OP_XORI;
      32'b????????????_?????_110___?????_0010011: op = `OP_ORI;
      32'b????????????_?????_111___?????_0010011: op = `OP_ANDI;

      32'b????????????_?????_000___?????_0001111: op = `OP_FENCE;

      32'b????????????_?????_000___?????_0000011: op = `OP_LB;
      32'b????????????_?????_001___?????_0000011: op = `OP_LH;
      32'b????????????_?????_010___?????_0000011: op = `OP_LW;
      32'b????????????_?????_100___?????_0000011: op = `OP_LBU;
      32'b????????????_?????_101___?????_0000011: op = `OP_LHU;

      32'b????????????_?????_000___?????_1100111: op = `OP_JALR;

      32'b0000000?????_?????_001___?????_0010011: op = `OP_SLLI;
      32'b0000000?????_?????_101___?????_0010011: op = `OP_SRLI;
      32'b0100000?????_?????_101___?????_0010011: op = `OP_SRAI;

      32'b000000000000_00000_000___00000_1110011: op = `OP_ECALL;
      32'b000000000001_00000_000___00000_1110011: op = `OP_EBREAK;

      // R-Type
      //  func7   rs2   rs1   func3 rd    op
      32'b0000000_?????_?????_000___?????_0110011: op = `OP_ADD;
      32'b0100000_?????_?????_000___?????_0110011: op = `OP_SUB;
      32'b0000000_?????_?????_001___?????_0110011: op = `OP_SLL;
      32'b0000000_?????_?????_010___?????_0110011: op = `OP_SLT;
      32'b0000000_?????_?????_011___?????_0110011: op = `OP_SLTU;
      32'b0000000_?????_?????_100___?????_0110011: op = `OP_XOR;
      32'b0000000_?????_?????_101___?????_0110011: op = `OP_SRL;
      32'b0100000_?????_?????_101___?????_0110011: op = `OP_SRA;
      32'b0000000_?????_?????_110___?????_0110011: op = `OP_OR;
      32'b0000000_?????_?????_111___?????_0110011: op = `OP_AND;

      // S-Type
      //  imm[11:5] rs2   rs1   func3 imm[4:0] op
      32'b???????___?????_?????_000___?????____0100011: op = `OP_SB;
      32'b???????___?????_?????_001___?????____0100011: op = `OP_SH;
      32'b???????___?????_?????_010___?????____0100011: op = `OP_SW;

      // B-Type
      //  imm[12] imm[10:5] rs2   rs1   func3 imm[4:1] imm[11] op
      32'b?_______??????____?????_?????_000___????_____?_______1100011: op = `OP_BEQ;
      32'b?_______??????____?????_?????_001___????_____?_______1100011: op = `OP_BNE;
      32'b?_______??????____?????_?????_100___????_____?_______1100011: op = `OP_BLT;
      32'b?_______??????____?????_?????_101___????_____?_______1100011: op = `OP_BGE;
      32'b?_______??????____?????_?????_110___????_____?_______1100011: op = `OP_BLTU;
      32'b?_______??????____?????_?????_111___????_____?_______1100011: op = `OP_BGEU;

      // J-Type
      //  imm[20] imm[10:1]  imm[11] imm[19:12] rd    op
      32'b?_______??????????_?_______????????___?????_1101111: op = `OP_JAL;

      default: op = `OP_ILLEGAL;
    endcase

    // immediate
    casez (op)
      // U-Type
      //    imm[31:12]           rd    op
      //32'b????????????????????_?????_???????
      `OP_LUI, `OP_AUIPC:
        imm = {instruction32[31:12], 12'd0};

      // I-Type
      //    imm[11:0]    rs1   func3 rd    op
      //32'b????????????_?????_???___?????_???????
      `OP_ADDI, `OP_SLTI, `OP_SLTIU, `OP_XORI, `OP_ORI, `OP_ANDI, `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU, `OP_JALR:
        imm = { {20{instruction32[31]}}, instruction32[31:20]}; // sext

      // only use lower 5 bits for offset
      `OP_SLLI, `OP_SRLI, `OP_SRAI:
        imm = {27'd0, instruction32[24:20]};

      // R-Type
      //    func7   rs2   rs1   func3 rd    op
      //32'b???????_?????_?????_???___?????_???????
      `OP_ADD, `OP_SUB, `OP_SLL, `OP_SLT, `OP_SLTU, `OP_XOR, `OP_SRL, `OP_SRA, `OP_OR, `OP_AND:
        imm = 32'd0;

      // S-Type
      //    imm[11:5] rs2   rs1   func3 imm[4:0] op
      //32'b???????___?????_?????_???___?????____???????
      `OP_SB, `OP_SH, `OP_SW:
        imm = { {20{instruction32[31]}}, instruction32[31:25], instruction32[11:7]}; // sext

      // B-Type
      //    imm[12] imm[10:5] rs2   rs1   func3 imm[4:1] imm[11] op
      //32'b?_______??????____?????_?????_???___????_____?_______???????
      // imm[0] implicitly 0 for 2-byte allignment (for the commpressed version ig)
      `OP_BEQ, `OP_BNE, `OP_BLT, `OP_BGE, `OP_BLTU, `OP_BGEU:
        imm = { {19{instruction32[31]}}, instruction32[31], instruction32[7], instruction32[30:25], instruction32[11:8], 1'b0}; // sext

      // J-Type
      //    imm[20] imm[10:1]  imm[11] imm[19:12] rd    op
      //32'b?_______??????????_?_______????????___?????_1101111
      `OP_JAL:
        imm = { {11{instruction32[31]}}, instruction32[31], instruction32[19:12], instruction32[20], instruction32[30:21], 1'b0}; // sext

      // ommited instructions
      // ECALL- we've got no system or privlage
      // EBREAK - i'm not doing a debugger
      // also i haven't even done interupts lol
      // FENCE - no threading (for now?)
      `OP_ECALL, `OP_EBREAK, `OP_FENCE: begin 
        imm = 32'd0;
        rs1 = 0;
        rs2 = 0;
        imm = 0;
        rd = 0;
      end

      `OP_ILLEGAL:
        imm = 32'd0;

      default:
        imm = 32'd0; // uh oh
    endcase
  end
endmodule

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