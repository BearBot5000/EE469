onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/cpu/clk
add wave -noupdate /testbench/cpu/rst
add wave -noupdate /testbench/cpu/PC
add wave -noupdate /testbench/cpu/Instr
add wave -noupdate /testbench/cpu/ALUResult
add wave -noupdate /testbench/cpu/WriteData
add wave -noupdate /testbench/cpu/MemWrite
add wave -noupdate /testbench/cpu/ReadData
add wave -noupdate /testbench/cpu/processor/u_reg_file/wr_en
add wave -noupdate /testbench/cpu/processor/u_reg_file/write_data
add wave -noupdate /testbench/cpu/processor/u_reg_file/write_addr
add wave -noupdate /testbench/cpu/processor/u_reg_file/read_addr1
add wave -noupdate /testbench/cpu/processor/u_reg_file/read_addr2
add wave -noupdate /testbench/cpu/processor/u_reg_file/read_data1
add wave -noupdate /testbench/cpu/processor/u_reg_file/read_data2
add wave -noupdate /testbench/cpu/processor/u_reg_file/memory
add wave -noupdate /testbench/cpu/processor/u_alu/a
add wave -noupdate /testbench/cpu/processor/u_alu/b
add wave -noupdate /testbench/cpu/processor/u_alu/ALUControl
add wave -noupdate /testbench/cpu/processor/u_alu/Result
add wave -noupdate /testbench/cpu/processor/u_alu/ALUFlags
add wave -noupdate /testbench/cpu/processor/u_alu/karry
add wave -noupdate /testbench/cpu/processor/Result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {76 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 395
configure wave -valuecolwidth 237
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
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ps} {896 ps}
