onerror {resume}
radix define operation {
    "0" "OP_LUI",
    "1" "OP_AUIPC",
    "2" "OP_ADDI",
    "3" "OP_SLTI",
    "4" "OP_SLTIU",
    "5" "OP_XORI",
    "6" "OP_ORI",
    "7" "OP_ANDI",
    "8" "OP_SLLI",
    "9" "OP_SRLI",
    "10" "OP_SRAI",
    "11" "OP_ADD",
    "12" "OP_SUB",
    "13" "OP_SLL",
    "14" "OP_SLT",
    "15" "OP_SLTU",
    "16" "OP_XOR",
    "17" "OP_SRL",
    "18" "OP_SRA",
    "19" "OP_OR",
    "20" "OP_AND",
    "21" "OP_FENCE",
    "22" "OP_ECALL",
    "23" "OP_EBREAK",
    "24" "OP_LB",
    "25" "OP_LH",
    "26" "OP_LW",
    "27" "OP_LBU",
    "28" "OP_LHU",
    "29" "OP_SB",
    "30" "OP_SH",
    "31" "OP_SW",
    "32" "OP_JAL",
    "33" "OP_JALR",
    "34" "OP_BEQ",
    "35" "OP_BNE",
    "36" "OP_BLT",
    "37" "OP_BGE",
    "38" "OP_BLTU",
    "39" "OP_BGEU",
    "40" "OP_ILLEGAL",
    -default default
}
radix define processor_state {
    "0" "START_FETCH",
    "1" "FETCH",
    "2" "START_MEM",
    "3" "MEM_ACCESS",
    "4" "WRITEBACK",
    -default default
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv/CLOCK_50
add wave -noupdate /riscv/FL_ADDR
add wave -noupdate /riscv/FL_DQ
add wave -noupdate /riscv/FL_OE_N
add wave -noupdate /riscv/FL_RST_N
add wave -noupdate /riscv/FL_WE_N
add wave -noupdate /riscv/SRAM_ADDR
add wave -noupdate /riscv/SRAM_DQ
add wave -noupdate /riscv/SRAM_WE_N
add wave -noupdate /riscv/SRAM_OE_N
add wave -noupdate /riscv/SRAM_UB_N
add wave -noupdate /riscv/SRAM_LB_N
add wave -noupdate /riscv/SRAM_CE_N
add wave -noupdate /riscv/SW
add wave -noupdate /riscv/KEY
add wave -noupdate /riscv/LEDR
add wave -noupdate /riscv/LEDG
add wave -noupdate /riscv/HEX0
add wave -noupdate /riscv/HEX1
add wave -noupdate /riscv/HEX2
add wave -noupdate /riscv/HEX3
add wave -noupdate /riscv/rst_n
add wave -noupdate -radix processor_state /riscv/processor_state
add wave -noupdate -radix operation /riscv/decoder_op
add wave -noupdate /riscv/mem_mux_finished
add wave -noupdate /riscv/memory_write_request
add wave -noupdate /riscv/memory_read_request
add wave -noupdate /riscv/memory_byte_mode
add wave -noupdate /riscv/memory_addr
add wave -noupdate /riscv/memory_data_in
add wave -noupdate /riscv/memory_data_out
add wave -noupdate /riscv/memory_busy
add wave -noupdate /riscv/memory_finished
add wave -noupdate /riscv/fetch_read_request
add wave -noupdate /riscv/fetch_addr
add wave -noupdate /riscv/fetch_result
add wave -noupdate /riscv/mem_access_read_request
add wave -noupdate /riscv/mem_access_write_request
add wave -noupdate /riscv/mem_access_addr
add wave -noupdate /riscv/mem_access_data_in
add wave -noupdate /riscv/mem_access_byte_mode
add wave -noupdate /riscv/mem_access_data_out
add wave -noupdate /riscv/rs1_bank_interface_in
add wave -noupdate /riscv/rs2_bank_interface_in
add wave -noupdate /riscv/rs1_bank_interface_out
add wave -noupdate /riscv/rs2_bank_interface_out
add wave -noupdate /riscv/rd_writeback_reg
add wave -noupdate /riscv/rd_writeback_val
add wave -noupdate /riscv/next_pc
add wave -noupdate /riscv/pc
add wave -noupdate /riscv/instruction32
add wave -noupdate /riscv/ins_valid
add wave -noupdate /riscv/decoder_rd
add wave -noupdate /riscv/decoder_rs1
add wave -noupdate /riscv/decoder_rs2
add wave -noupdate /riscv/decoder_imm
add wave -noupdate /riscv/execute_result
add wave -noupdate /riscv/memory_access_result
add wave -noupdate /riscv/mem/clk
add wave -noupdate /riscv/mem/rst_n
add wave -noupdate /riscv/mem/write_request
add wave -noupdate /riscv/mem/read_request
add wave -noupdate /riscv/mem/byte_mode
add wave -noupdate /riscv/mem/addr_in
add wave -noupdate /riscv/mem/data_in
add wave -noupdate /riscv/mem/data_out
add wave -noupdate /riscv/mem/busy
add wave -noupdate /riscv/mem/finished
add wave -noupdate /riscv/mem/FL_ADDR
add wave -noupdate /riscv/mem/FL_DQ
add wave -noupdate /riscv/mem/FL_OE_N
add wave -noupdate /riscv/mem/FL_RST_N
add wave -noupdate /riscv/mem/FL_WE_N
add wave -noupdate /riscv/mem/SRAM_ADDR
add wave -noupdate /riscv/mem/SRAM_DQ
add wave -noupdate /riscv/mem/SRAM_WE_N
add wave -noupdate /riscv/mem/SRAM_OE_N
add wave -noupdate /riscv/mem/SRAM_UB_N
add wave -noupdate /riscv/mem/SRAM_LB_N
add wave -noupdate /riscv/mem/SRAM_CE_N
add wave -noupdate /riscv/mem/flash_read_request
add wave -noupdate /riscv/mem/flash_addr
add wave -noupdate /riscv/mem/flash_data
add wave -noupdate /riscv/mem/flash_finished
add wave -noupdate /riscv/mem/flash_busy
add wave -noupdate /riscv/mem/flash_byte_mode
add wave -noupdate /riscv/mem/sram_read_request
add wave -noupdate /riscv/mem/sram_write_request
add wave -noupdate /riscv/mem/sram_addr
add wave -noupdate /riscv/mem/sram_data_in
add wave -noupdate /riscv/mem/sram_data_out
add wave -noupdate /riscv/mem/sram_finished
add wave -noupdate /riscv/mem/sram_busy
add wave -noupdate /riscv/mem/sram_byte_mode
add wave -noupdate /riscv/mem/last_module
add wave -noupdate /riscv/mem/next_module
add wave -noupdate /riscv/memory_multiplexer/rst_n
add wave -noupdate /riscv/memory_multiplexer/processor_state
add wave -noupdate /riscv/memory_multiplexer/fetch_read_request
add wave -noupdate /riscv/memory_multiplexer/fetch_addr
add wave -noupdate /riscv/memory_multiplexer/fetch_result
add wave -noupdate /riscv/memory_multiplexer/mem_access_read_request
add wave -noupdate /riscv/memory_multiplexer/mem_access_write_request
add wave -noupdate /riscv/memory_multiplexer/mem_access_addr
add wave -noupdate /riscv/memory_multiplexer/mem_access_data_in
add wave -noupdate /riscv/memory_multiplexer/mem_access_byte_mode
add wave -noupdate /riscv/memory_multiplexer/mem_access_data_out
add wave -noupdate /riscv/memory_multiplexer/finished
add wave -noupdate /riscv/memory_multiplexer/memory_read_request
add wave -noupdate /riscv/memory_multiplexer/memory_write_request
add wave -noupdate /riscv/memory_multiplexer/memory_byte_mode
add wave -noupdate /riscv/memory_multiplexer/memory_addr
add wave -noupdate /riscv/memory_multiplexer/memory_data_in
add wave -noupdate /riscv/memory_multiplexer/memory_data_out
add wave -noupdate /riscv/memory_multiplexer/memory_finished
add wave -noupdate /riscv/reg_bank/clk
add wave -noupdate /riscv/reg_bank/rst_n
add wave -noupdate /riscv/reg_bank/processor_state
add wave -noupdate /riscv/reg_bank/rs1_bank_interface_in
add wave -noupdate /riscv/reg_bank/rs2_bank_interface_in
add wave -noupdate /riscv/reg_bank/rs1_bank_interface_out
add wave -noupdate /riscv/reg_bank/rs2_bank_interface_out
add wave -noupdate /riscv/reg_bank/rd_writeback_reg
add wave -noupdate /riscv/reg_bank/rd_writeback_val
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {917397 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
configure wave -valuecolwidth 208
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {900516 ps} {1973658 ps}
