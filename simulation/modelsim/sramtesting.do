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
# -- Compiling module button_debounce
# -- Compiling module hex_to_7seg
# -- Compiling module display_32bit_7seg
# 
# Top level modules:
# 	button_debounce
# 	display_32bit_7seg
# 
vsim work.sram_interface32bit
# vsim work.sram_interface32bit 
# Loading work.sram_interface32bit

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate /sram_interface32bit/clk
add wave -noupdate /sram_interface32bit/rst_n
add wave -noupdate /sram_interface32bit/write_request
add wave -noupdate /sram_interface32bit/read_request
add wave -noupdate /sram_interface32bit/byte_mode
add wave -noupdate -radix hexadecimal /sram_interface32bit/addr
add wave -noupdate -radix hexadecimal /sram_interface32bit/write_data
add wave -noupdate -divider Outputs
add wave -noupdate -radix hexadecimal /sram_interface32bit/interface_addr
add wave -noupdate /sram_interface32bit/interface_output_enable_n
add wave -noupdate /sram_interface32bit/interface_write_enable_n
add wave -noupdate /sram_interface32bit/interface_upper_byte_mask_n
add wave -noupdate /sram_interface32bit/interface_lower_byte_mask_n
add wave -noupdate /sram_interface32bit/finished
add wave -noupdate /sram_interface32bit/busy
add wave -noupdate -radix hexadecimal /sram_interface32bit/data_out
add wave -noupdate -divider Internal
add wave -noupdate -radix hexadecimal /sram_interface32bit/write_halfword
add wave -noupdate -radix unsigned /sram_interface32bit/state
add wave -noupdate -radix unsigned /sram_interface32bit/next_state
add wave -noupdate /sram_interface32bit/writing
add wave -noupdate -divider Inout
add wave -noupdate -radix hexadecimal /sram_interface32bit/interface_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159243 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 299
configure wave -valuecolwidth 223
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
configure wave -timelineunits ps
update
WaveRestoreZoom {7424 ps} {309504 ps}


force -freeze sim:/sram_interface32bit/clk 0 0, 1 10 ns -r 20 ns

force -freeze sim:/sram_interface32bit/write_request 0 0
force -freeze sim:/sram_interface32bit/read_request 0 0
force -freeze sim:/sram_interface32bit/byte_mode 0 0
force -freeze sim:/sram_interface32bit/addr 0 0
force -freeze sim:/sram_interface32bit/write_data 1 0
force -freeze sim:/sram_interface32bit/rst_n 0 0
run 20 ns
force -freeze sim:/sram_interface32bit/rst_n 1 0
force -freeze sim:/sram_interface32bit/rst_n 1 0
force -freeze sim:/sram_interface32bit/write_request 1 0
run 20 ns
force -freeze sim:/sram_interface32bit/write_request 0 0
run 20 ns
force -freeze sim:/sram_interface32bit/write_request St0 0
run 20 ns
force -freeze sim:/sram_interface32bit/addr 1 0
force -freeze sim:/sram_interface32bit/write_data 0 0
run 20 ns
force -freeze sim:/sram_interface32bit/write_request 1 0
run 20 ns
force -freeze sim:/sram_interface32bit/write_request 0 0
run 20 ns
run 20 ns
run 20 ns

