onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mips_testbench/mips/clk
add wave -noupdate /mips_testbench/mips/reset
add wave -noupdate -divider ROB
add wave -noupdate /mips_testbench/mips/load_ROB_head
add wave -noupdate /mips_testbench/mips/next_ROB_head
add wave -noupdate /mips_testbench/mips/ROB_head
add wave -noupdate /mips_testbench/mips/load_ROB_tail
add wave -noupdate /mips_testbench/mips/next_ROB_tail
add wave -noupdate /mips_testbench/mips/ROB_tail
add wave -noupdate /mips_testbench/mips/jump_ID
add wave -noupdate /mips_testbench/mips/ROB_exception_head
add wave -noupdate /mips_testbench/mips/ROB_empty_entries
add wave -noupdate /mips_testbench/mips/ROB_state_head
add wave -noupdate /mips_testbench/mips/ROB_addr_head
add wave -noupdate /mips_testbench/mips/ROB_value_head
add wave -noupdate /mips_testbench/mips/ROB_PC_head
add wave -noupdate /mips_testbench/mips/ROB_instr_head
add wave -noupdate /mips_testbench/mips/ROB_rs_state
add wave -noupdate /mips_testbench/mips/ROB_rt_state
add wave -noupdate /mips_testbench/mips/ROB_rs_value
add wave -noupdate /mips_testbench/mips/ROB_rt_value
add wave -noupdate /mips_testbench/mips/ROB/ROB_states
add wave -noupdate -divider {SPECIAL REG}
add wave -noupdate /mips_testbench/mips/rm0_out
add wave -noupdate /mips_testbench/mips/rm1_out
add wave -noupdate /mips_testbench/mips/rm2_out
add wave -noupdate /mips_testbench/mips/rm4_out
add wave -noupdate /mips_testbench/mips/paddr_LU
add wave -noupdate /mips_testbench/mips/hit_iCache_IF
add wave -noupdate -divider RAM
add wave -noupdate /mips_testbench/mips/RAM/addr_r
add wave -noupdate /mips_testbench/mips/read_rw_RAM
add wave -noupdate /mips_testbench/mips/read_r_RAM
add wave -noupdate /mips_testbench/mips/write_rw_RAM
add wave -noupdate /mips_testbench/mips/port_rw_state_RAM
add wave -noupdate /mips_testbench/mips/port_r_state_RAM
add wave -noupdate /mips_testbench/mips/dout_rw_RAM
add wave -noupdate /mips_testbench/mips/dout_r_RAM
add wave -noupdate -divider iTLB
add wave -noupdate /mips_testbench/mips/iTLB/hit
add wave -noupdate /mips_testbench/mips/iTLB/paddr
add wave -noupdate -divider dTLB
add wave -noupdate -divider dCache
add wave -noupdate -divider iCache
add wave -noupdate /mips_testbench/mips/iCache/data_idx
add wave -noupdate /mips_testbench/mips/iCache/data_word
add wave -noupdate /mips_testbench/mips/iCache/data_tag
add wave -noupdate /mips_testbench/mips/iCache/addr_tag
add wave -noupdate /mips_testbench/mips/iCache/addr_data
add wave -noupdate /mips_testbench/mips/iCache/write_data
add wave -noupdate -expand /mips_testbench/mips/iCache/cache_data
add wave -noupdate /mips_testbench/mips/iCache/cache_valid
add wave -noupdate -expand /mips_testbench/mips/iCache/cache_tags
add wave -noupdate /mips_testbench/mips/iCache/hit
add wave -noupdate /mips_testbench/mips/iCache/dout_tag
add wave -noupdate -divider IF
add wave -noupdate /mips_testbench/mips/PC_in_IF
add wave -noupdate /mips_testbench/mips/PC4_IF
add wave -noupdate /mips_testbench/mips/PC_out_IF
add wave -noupdate /mips_testbench/mips/instruction_IF_out
add wave -noupdate -divider ID
add wave -noupdate /mips_testbench/mips/PC_ID
add wave -noupdate /mips_testbench/mips/instruction_ID
add wave -noupdate /mips_testbench/mips/ext_inm_ID
add wave -noupdate /mips_testbench/mips/bus_rs_ID
add wave -noupdate /mips_testbench/mips/bus_rt_ID
add wave -noupdate /mips_testbench/mips/bus_rs_out_ID
add wave -noupdate /mips_testbench/mips/bus_rt_out_ID
add wave -noupdate -divider EX
add wave -noupdate /mips_testbench/mips/instruction_EX
add wave -noupdate /mips_testbench/mips/bus_rs_EX
add wave -noupdate /mips_testbench/mips/bus_rt_EX
add wave -noupdate /mips_testbench/mips/PC_EX
add wave -noupdate /mips_testbench/mips/ext_inm_EX
add wave -noupdate /mips_testbench/mips/ALU_out_EX
add wave -noupdate -divider LU
add wave -noupdate /mips_testbench/mips/instruction_LU
add wave -noupdate /mips_testbench/mips/ALU_out_LU
add wave -noupdate /mips_testbench/mips/tag_LU
add wave -noupdate -divider MEM
add wave -noupdate /mips_testbench/mips/paddr_MEM
add wave -noupdate /mips_testbench/mips/instruction_MEM
add wave -noupdate /mips_testbench/mips/tag_MEM
add wave -noupdate /mips_testbench/mips/ALU_out_MEM
add wave -noupdate -divider MUL4
add wave -noupdate /mips_testbench/mips/instruction_MUL4
add wave -noupdate /mips_testbench/mips/tag_MUL4
add wave -noupdate /mips_testbench/mips/ALU_out_MUL4
add wave -noupdate -divider MUL5
add wave -noupdate /mips_testbench/mips/instruction_MUL5
add wave -noupdate /mips_testbench/mips/ALU_out_MUL5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2029310 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 267
configure wave -valuecolwidth 233
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
WaveRestoreZoom {1822380 ps} {2230380 ps}
