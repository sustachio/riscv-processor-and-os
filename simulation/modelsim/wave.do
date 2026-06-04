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
