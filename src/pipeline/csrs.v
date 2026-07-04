`include "global_constants.vh"

module control_status_registers(
  input clk,
  input rst_n,

  input [2:0] processor_state,
  input [1:0] processor_privilege,
  input TEST_ALLOW_WB_COMPLETE,

  input external_irq,
  input timer_irq,

  input [5:0] op,
  input [31:0] imm,
  input [31:0] rs1_val,
  input [11:0] csr_i, // only valid on csr instructions

  output reg [31:0] csr_read,

  // trap handling
  output reg [63:0] mstatus,
  output reg [31:0] mtvec,
  output reg [31:0] mcause,
  output reg [31:0] mtval,
  output reg [31:0] mepc,

  output reg [31:0] mie,
  output reg [31:0] mip,

  // misc
  output reg [31:0] mscratch,

  // set by trap handler
  input [63:0] next_mstatus,
  input [31:0] next_mtvec,
  input [31:0] next_mcause,
  input [31:0] next_mtval,
  input [31:0] next_mepc,

  output reg illegal_csr_access,
  output reg [31:0] TEST_PROBE_NEW_CSR_VAL
);
  reg [1:0] required_priv;
  reg instruction_is_csr_op;

  reg [31:0] new_csr_value;
  always @(*)
    TEST_PROBE_NEW_CSR_VAL = new_csr_value;

  always @(*) begin
    if (!rst_n) begin
      csr_read = 0;
      mip = 0;
    end else begin
      mip = 0;
      mip[11] = external_irq;
      mip[7]  = timer_irq;

      instruction_is_csr_op = (op == `OP_CSRRW  ||
                               op == `OP_CSRRS  ||
                               op == `OP_CSRRC  ||
                               op == `OP_CSRRWI ||
                               op == `OP_CSRRSI ||
                               op == `OP_CSRRCI);

      case (csr_i)
        `CSR_CYCLE:     csr_read = 0; // TODO
        `CSR_CYCLEH:    csr_read = 0; // TODO
        `CSR_TIME:      csr_read = 0; // TODO
        `CSR_TIMEH:     csr_read = 0; // TODO
        `CSR_INSTRET:   csr_read = 0; // TODO
        `CSR_INSTRETH:  csr_read = 0; // TODO
        //hpmcounter3-31	0xC03-0xC1F
        //hpmcounter3-31h	0xC83-0xC9F
        `CSR_MISA:      csr_read = 32'b01000000000000000000000100000000; // RV32I
        `CSR_MVENDORID: csr_read = 0; // non-commerical
        `CSR_MARCHID:   csr_read = 0; // undef
        `CSR_MIMPID:    csr_read = 0; // undev
        `CSR_MHARTID:   csr_read = 0; // root is 0 (only one thread)
        `CSR_MSTATUS:   csr_read = mstatus[31:0];
        `CSR_MSTATUSH:  csr_read = mstatus[63:32];
        `CSR_MTVEC:     csr_read = mtvec;
        `CSR_MEDELEG :  csr_read = 0; // unimp, supervisor mode delegations
        `CSR_MEDELEGH:  csr_read = 0; // ^
        `CSR_MIDELEG :  csr_read = 0; // ^
        `CSR_MIP:       csr_read = mip;
        `CSR_MIE:       csr_read = mie;
        `CSR_MCYCLE:    csr_read = 0; // TODO
        `CSR_MCYCLEH:   csr_read = 0; // TODO
        `CSR_MINSTRET:  csr_read = 0; // TODO
        `CSR_MINSTRETH: csr_read = 0; // TODO
        //mhpmcounter3-31	0xB03-0xB1F
        //mhpmcounter3-31h	0xB84-0xB9F
        //mhpevent3-31	0x324-0x33F
        //mhpevent3-31h	0x324-0x33F
        `CSR_MCOUNTEREN:    csr_read = 0; // TODO
        `CSR_MCOUNTINHIBIT: csr_read = 0; // TODO
        `CSR_MSCRATCH:  csr_read = mscratch;
        `CSR_MEPC:      csr_read = mepc;
        `CSR_MCAUSE:    csr_read = mcause;
        `CSR_MTVAL:     csr_read = mtval;
        `CSR_MCONFIGPTR:csr_read = 0; // TODO
        `CSR_MENVCFG:   csr_read = 0; // no data structure exists
        `CSR_MENVCFGH : csr_read = 0; // TODO
        `CSR_MSECCFG:   csr_read = 0; // for extensions, none of which we have
        `CSR_MSECCFGH:  csr_read = 0; // ^
        // also the PMP stuff
        default: csr_read = 0;
      endcase
      case (csr_i)
        `CSR_CYCLE, `CSR_CYCLEH, `CSR_TIME, `CSR_TIMEH, `CSR_INSTRET, `CSR_INSTRETH:  
          required_priv = `PRIV_USER;
        //hpmcounter3-31	0xC03-0xC1F
        //hpmcounter3-31h	0xC83-0xC9F

        `CSR_MISA, `CSR_MVENDORID, `CSR_MARCHID, `CSR_MIMPID, `CSR_MHARTID, `CSR_MSTATUS, `CSR_MSTATUSH, `CSR_MTVEC, `CSR_MEDELEG , `CSR_MEDELEGH, `CSR_MIDELEG , `CSR_MIP, `CSR_MIE, `CSR_MCYCLE, `CSR_MCYCLEH, `CSR_MINSTRET, `CSR_MINSTRET, `CSR_MCOUNTEREN, `CSR_MCOUNTINHIBIT, `CSR_MSCRATCH, `CSR_MEPC, `CSR_MCAUSE, `CSR_MTVAL, `CSR_MCONFIGPTR, `CSR_MENVCFG, `CSR_MENVCFGH , `CSR_MSECCFG, `CSR_MSECCFGH:
          required_priv = `PRIV_MACHINE;
        //mhpmcounter3-31	0xB03-0xB1F
        //mhpmcounter3-31h	0xB84-0xB9F
        //mhpevent3-31	0x324-0x33F
        //mhpevent3-31h	0x324-0x33F
        // also the PMP stuff

        default: required_priv = `PRIV_USER;
      endcase

      case (op)
        `OP_CSRRW:  new_csr_value = rs1_val;
        `OP_CSRRS:  new_csr_value = csr_read |  rs1_val;
        `OP_CSRRC:  new_csr_value = csr_read & ~rs1_val;
        `OP_CSRRWI: new_csr_value = imm;
        `OP_CSRRSI: new_csr_value = csr_read |  imm;
        `OP_CSRRCI: new_csr_value = csr_read & ~imm;

        default: new_csr_value = csr_read;
      endcase

      illegal_csr_access = instruction_is_csr_op && (required_priv > processor_privilege);
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mstatus <= 0;
      mtvec <= 0;
      mcause <= 0;
      mtval <= 0;
      mepc <= 0;
      mscratch <= 0;
    end
    else begin
      // values set by trap_handler
      mstatus <= next_mstatus;
      mtvec <= next_mtvec;
      mepc <= next_mcause;
      mtval <= next_mtval;
      mepc <= next_mepc;

      if (instruction_is_csr_op && (processor_state == `WRITEBACK) && TEST_ALLOW_WB_COMPLETE && !illegal_csr_access) begin
        case (csr_i)
          `CSR_CYCLE:     begin end // TODO
          `CSR_CYCLEH:    begin end // TODO
          `CSR_TIME:      begin end // TODO
          `CSR_TIMEH:     begin end // TODO
          `CSR_INSTRET:   begin end // TODO
          `CSR_INSTRETH:  begin end // TODO
          //hpmcounter3-31	0xC03-0xC1F
          //hpmcounter3-31h	0xC83-0xC9F
          `CSR_MISA:      begin end // no write
          `CSR_MVENDORID: begin end // no write
          `CSR_MARCHID:   begin end // no write
          `CSR_MIMPID:    begin end // no write
          `CSR_MHARTID:   begin end // no write
          `CSR_MSTATUS:   mstatus[31:0]  <= new_csr_value;
          `CSR_MSTATUSH:  mstatus[63:32] <= new_csr_value;
          `CSR_MTVEC:     mtvec <= new_csr_value;
          `CSR_MEDELEG :  begin end // unimp, supervisor mode delegations
          `CSR_MEDELEGH:  begin end // ^
          `CSR_MIDELEG :  begin end // ^
          `CSR_MIP:       begin end // TODO
          `CSR_MIE:       mie <= new_csr_value; // TODO
          `CSR_MCYCLE:    begin end // TODO
          `CSR_MCYCLEH:   begin end // TODO
          `CSR_MINSTRET:  begin end // TODO
          `CSR_MINSTRETH:  begin end // TODO
          //mhpmcounter3-31	0xB03-0xB1F
          //mhpmcounter3-31h	0xB84-0xB9F
          //mhpevent3-31	0x324-0x33F
          //mhpevent3-31h	0x324-0x33F
          `CSR_MCOUNTEREN:    begin end // TODO
          `CSR_MCOUNTINHIBIT: begin end // TODO
          `CSR_MSCRATCH:  mscratch  <= new_csr_value;
          `CSR_MEPC:      mepc      <= new_csr_value; 
          `CSR_MCAUSE:    mcause    <= new_csr_value;
          `CSR_MTVAL:     mtval     <= new_csr_value;
          `CSR_MCONFIGPTR:begin end // TODO
          `CSR_MENVCFG:   begin end // no data structure exists
          `CSR_MENVCFGH : begin end // TODO
          `CSR_MSECCFG:   begin end // for extensions, none of which we have
          `CSR_MSECCFGH:  begin end // ^
          // also the PMP stuff
          default: begin end
        endcase
      end // WB
    end // !rst_n
  end // always
endmodule