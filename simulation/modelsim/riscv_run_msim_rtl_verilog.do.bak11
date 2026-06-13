transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/riscv.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/interfaces.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/utils.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/memory_mapped_io.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Seth\ Mueller/Documents/fpga {C:/Users/Seth Mueller/Documents/fpga/pipeline.v}

