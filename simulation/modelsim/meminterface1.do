onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /memory_controller/clk
add wave -noupdate -radix hexadecimal /memory_controller/rst_n
add wave -noupdate -divider inputs
add wave -noupdate -radix hexadecimal /memory_controller/write_request
add wave -noupdate -radix hexadecimal /memory_controller/read_request
add wave -noupdate -radix hexadecimal /memory_controller/byte_mode
add wave -noupdate -radix hexadecimal /memory_controller/addr_in
add wave -noupdate -radix hexadecimal /memory_controller/data_in
add wave -noupdate -divider outputs
add wave -noupdate -radix hexadecimal /memory_controller/data_out
add wave -noupdate -radix hexadecimal /memory_controller/busy
add wave -noupdate -radix hexadecimal /memory_controller/finished
add wave -noupdate -divider -height 50 hardware
add wave -noupdate -radix hexadecimal /memory_controller/FL_ADDR
add wave -noupdate -radix hexadecimal /memory_controller/FL_DQ
add wave -noupdate -radix hexadecimal /memory_controller/FL_OE_N
add wave -noupdate -radix hexadecimal /memory_controller/FL_RST_N
add wave -noupdate -radix hexadecimal /memory_controller/FL_WE_N
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_ADDR
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_DQ
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_WE_N
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_OE_N
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_UB_N
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_LB_N
add wave -noupdate -radix hexadecimal /memory_controller/SRAM_CE_N
add wave -noupdate -divider {flash interface}
add wave -noupdate -radix hexadecimal /memory_controller/flash32/interface_addr
add wave -noupdate -radix hexadecimal /memory_controller/flash32/interface_data
add wave -noupdate -radix hexadecimal /memory_controller/flash32/read_request
add wave -noupdate -radix hexadecimal /memory_controller/flash32/addr
add wave -noupdate -radix hexadecimal /memory_controller/flash32/data
add wave -noupdate -radix hexadecimal /memory_controller/flash32/finished
add wave -noupdate -radix hexadecimal /memory_controller/flash32/busy
add wave -noupdate -radix hexadecimal -radixenum symbolic /memory_controller/flash32/state
add wave -noupdate -radix hexadecimal /memory_controller/flash32/next_state
add wave -noupdate /memory_controller/last_module
add wave -noupdate -divider {sram}
add wave -noupdate -radix hexadecimal  sim:/memory_controller/sram32/interface_data
add wave -noupdate -radix hexadecimal  sim:/memory_controller/sram32/interface_addr
add wave -noupdate -radix hexadecimal  sim:/memory_controller/sram32/addr

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {446147 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
configure wave -valuecolwidth 97
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
WaveRestoreZoom {166701 ps} {475437 ps}


force -freeze sim:/memory_controller/clk 1 0, 0 {10000 ps} -r {20 ns}
force -freeze sim:/memory_controller/rst_n 0 0
force -freeze sim:/memory_controller/write_request 0 0
force -freeze sim:/memory_controller/read_request 1 0
force -freeze sim:/memory_controller/byte_mode 0 0
force -freeze sim:/memory_controller/addr_in 1 0
force -freeze sim:/memory_controller/data_in 0 0
force -freeze sim:/memory_controller/FL_DQ 00000011 0
force -freeze sim:/memory_controller/SRAM_DQ 0000000000100000 0
force -freeze sim:/memory_controller/flash32/interface_data 00000011 0

run 20 ns
force -freeze sim:/memory_controller/rst_n 1 0
run 20 ns
force -freeze sim:/memory_controller/read_request 0 0
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
force -freeze sim:/memory_controller/addr_in 00010000000000000000000000000001 0
run 20 ns
run 20 ns
force -freeze sim:/memory_controller/read_request 1 0
run 20 ns
force -freeze sim:/memory_controller/read_request 0 0
run 20 ns
force -freeze sim:/memory_controller/sram32/interface_data 0000000000100000 0
run 20 ns
run 20 ns
run 20 ns
