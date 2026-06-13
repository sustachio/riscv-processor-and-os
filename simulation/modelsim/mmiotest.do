# Reading C:/altera/13.0sp1/modelsim_ase/tcl/vsim/pref.tcl 
# do riscv_run_msim_rtl_verilog.do 
# if {[file exists rtl_work]} {
# 	vdel -lib rtl_work -all
# }
# vlib rtl_work
# vmap work rtl_work
# Copying C:\altera\13.0sp1\modelsim_ase\win32aloem/../modelsim.ini to modelsim.ini
# Modifying modelsim.ini
# ** Warning: Copied C:\altera\13.0sp1\modelsim_ase\win32aloem/../modelsim.ini to modelsim.ini.
#          Updated modelsim.ini.
# 
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/riscv.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module riscv
# 
# Top level modules:
# 	riscv
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/interfaces.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module flash_interface32bit
# -- Compiling module sram_interface32bit
# 
# Top level modules:
# 	flash_interface32bit
# 	sram_interface32bit
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/utils.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module rst_n_init
# -- Compiling module button_debounce
# -- Compiling module hex_to_7seg
# -- Compiling module display_32bit_7seg
# 
# Top level modules:
# 	rst_n_init
# 	button_debounce
# 	display_32bit_7seg
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/memory_mapped_io.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module memory_mapped_io
# 
# Top level modules:
# 	memory_mapped_io
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/memory.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module memory_multiplexer
# -- Compiling module memory_controller
# 
# Top level modules:
# 	memory_multiplexer
# 	memory_controller
# vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/pipeline.v}
# Model Technology ModelSim ALTERA vlog 10.1d Compiler 2012.11 Nov  2 2012
# -- Compiling module processor_state_manager
# -- Compiling module reg_bank
# -- Compiling module instruction_fetch_and_pc
# -- Compiling module decoder
# -- Compiling module execute
# -- Compiling module memory_access
# -- Compiling module reg_writeback
# 
# Top level modules:
# 	processor_state_manager
# 	reg_bank
# 	instruction_fetch_and_pc
# 	decoder
# 	execute
# 	memory_access
# 	reg_writeback
# 
vsim work.riscv
# vsim work.riscv 
# Loading work.riscv
# Loading work.rst_n_init
# Loading work.processor_state_manager
# Loading work.memory_controller
# Loading work.flash_interface32bit
# Loading work.sram_interface32bit
# Loading work.memory_mapped_io
# Loading work.memory_multiplexer
# Loading work.reg_bank
# Loading work.instruction_fetch_and_pc
# Loading work.decoder
# Loading work.execute
# Loading work.memory_access
# Loading work.reg_writeback
# Loading work.button_debounce
# Loading work.display_32bit_7seg
# Loading work.hex_to_7seg
# ** Warning: (vsim-3017) C:/Users/Seth Mueller/Documents/fpga/memory.v(187): [TFMPC] - Too few port connections. Expected 17, found 16.
# 
#         Region: /riscv/mem/sram32
# ** Warning: (vsim-3722) C:/Users/Seth Mueller/Documents/fpga/memory.v(187): [TFMPC] - Missing connection for port 'TEST_EXPOSE_STATE'.
# 
# ** Warning: (vsim-3017) C:/Users/Seth Mueller/Documents/fpga/riscv.v(253): [TFMPC] - Too few port connections. Expected 15, found 14.
# 
#         Region: /riscv/memory_access
# ** Warning: (vsim-3722) C:/Users/Seth Mueller/Documents/fpga/riscv.v(253): [TFMPC] - Missing connection for port 'mem_access_busy'.
# 
do ../../fullwave.do
# ** Error: (vish-4014) No objects found matching '/riscv/ins_valid'.
# Executing ONERROR command at macro ./../../fullwave.do line 106
add wave -position insertpoint  \
sim:/riscv/TEST_ALLOW_WB_COMPLETE
force -freeze sim:/riscv/TEST_ALLOW_WB_COMPLETE 1 0
force -deposit sim:/riscv/CLOCK_50 0 0, 1 10 ns -r 20 ns
force -freeze sim:/riscv/fetch_result 00110000000000000000011110110111 0
run 200 ns
run 100 ns
run 40 ns
run 40 ns
run 40 ns
run 40 ns
run 40 ns
run 40 ns
force -freeze sim:/riscv/fetch_result 00010101010100000000011100010011 0
run 400 ns
run 40 ns
run 40 ns
add wave -position end  sim:/riscv/mem/memory_mapped_io/clk
add wave -position end  sim:/riscv/mem/memory_mapped_io/rst_n
add wave -position end  sim:/riscv/mem/memory_mapped_io/read_request
add wave -position end  sim:/riscv/mem/memory_mapped_io/write_request
add wave -position end  sim:/riscv/mem/memory_mapped_io/addr
add wave -position end  sim:/riscv/mem/memory_mapped_io/data_in
add wave -position end  sim:/riscv/mem/memory_mapped_io/data_out
add wave -position end  sim:/riscv/mem/memory_mapped_io/finished
add wave -position end  sim:/riscv/mem/memory_mapped_io/busy
add wave -position end  sim:/riscv/mem/memory_mapped_io/LEDR
add wave -position end  sim:/riscv/mem/memory_mapped_io/state
add wave -position end  sim:/riscv/mem/memory_mapped_io/next_state
force -freeze sim:/riscv/fetch_result 00000000111001111010000000100011 0
run 400 ns
run 20 ns
run 100 ns
