`include "global_constants.vh"

// todo: illegal instrucitons, misaligned instructions
module trap_manager(
  input clk,
  input rst_n,

  input [31:0] pc,
  input [31:0] execute_next_pc,
  output reg [31:0] next_pc,

  input [5:0] op,

  input illegal_csr_access,

  input [2:0] processor_state,
  input [1:0] processor_privilege,
  output reg [1:0] next_privilege,

  input [63:0] mstatus,
  input [31:0] mtvec,
  input [31:0] mcause,
  input [31:0] mtval,
  input [31:0] mepc,

  input [31:0] mip,
	input [31:0] mie,

  output reg [63:0] next_mstatus,
  output reg [31:0] next_mtvec,
  output reg [31:0] next_mcause,
  output reg [31:0] next_mtval,
  output reg [31:0] next_mepc
);
  wire ecall = op == `OP_ECALL;
  //wire ebreak = op == `OP_EBREAK;
  wire ebreak = 0;
  wire mret = op == `OP_MRET;

  wire external_irq = mip[`CSR_MIP_MEIP] & mstatus[`CSR_MSTATUS_MIE] & mie[`CSR_MIE_MEIE];
  wire timer_irq = mip[`CSR_MIP_MTIP] & mstatus[`CSR_MSTATUS_MIE] & mie[`CSR_MIE_MTIE];

  always @(*) begin
    if (!rst_n) begin
      next_pc = 0;
      next_privilege = 0;
      next_mstatus = 0;
      next_mtvec = 0;
      next_mcause = 0;
      next_mtval = 0;
      next_mepc = 0;
    end else begin
      // defaults
      next_pc = execute_next_pc;
      next_privilege = processor_privilege;
      next_mstatus = mstatus;
      next_mtvec = mtvec;
      next_mcause = mcause;
      next_mtval = mtval;
      next_mepc = mepc;

      // take trap?
      if (ecall || ebreak || illegal_csr_access || external_irq || timer_irq) begin
        next_privilege = `PRIV_MACHINE;
        next_mepc = pc;
        
        // save state
        next_mstatus[`CSR_MSTATUS_MPIE] = mstatus[`CSR_MSTATUS_MIE];
        next_mstatus[`CSR_MSTATUS_MIE] = 1'b0;
        next_mstatus[`CSR_MSTATUS_MPP:`CSR_MSTATUS_MPP-1] = processor_privilege;

        // set mcause
        if (ecall && processor_privilege == `PRIV_MACHINE) next_mcause = `TRAPCAUSE_ECALL_M;
        else if (ecall) next_mcause = `TRAPCAUSE_ECALL_U;
        else if (ebreak) next_mcause = `TRAPCAUSE_EBREAK;
        else if (illegal_csr_access) next_mcause = `TRAPCAUSE_ILLEGAL_INSTRUCTION;

        else if (external_irq) next_mcause = `TRAPCAUSE_MEI;
        else if (timer_irq)    next_mcause = `TRAPCAUSE_MTI;

        if (mtvec[1:0] == `MTVEC_DIRECT) begin
          next_pc = mtvec & (~32'b11);
        end else begin
          next_pc = (mtvec & (~32'b11)) + (4 * next_mcause[5:0]);
				end
      end

      // exit trap?
      if (mret) begin
        next_privilege = mstatus[`CSR_MSTATUS_MPP:`CSR_MSTATUS_MPP-1];

        next_mstatus[`CSR_MSTATUS_MIE] = mstatus[`CSR_MSTATUS_MPIE];
        next_mstatus[`CSR_MSTATUS_MPIE] = 1;
        next_mstatus[`CSR_MSTATUS_MPP:`CSR_MSTATUS_MPP-1] = `PRIV_USER;

        next_pc = mepc;
      end
    end
  end
endmodule