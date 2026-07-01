transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src {C:/Users/Seth Mueller/Documents/fpga/src/utils.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/memory_mapped_io.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/flash.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/sram.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/vga.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src {C:/Users/Seth Mueller/Documents/fpga/src/riscv.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/interfaces {C:/Users/Seth Mueller/Documents/fpga/src/interfaces/ps2.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/processorstate.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/regbank.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/fetch.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/decoder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/execute.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/memoryaccess.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/writeback.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga/src/pipeline {C:/Users/Seth Mueller/Documents/fpga/src/pipeline/csrs.v}

