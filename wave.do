onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/cpu/clk
add wave -noupdate /testbench/cpu/rst
add wave -noupdate /testbench/cpu/PC
add wave -noupdate /testbench/cpu/Instr
add wave -noupdate -expand /testbench/cpu/ALUResult
add wave -noupdate /testbench/cpu/WriteData
add wave -noupdate /testbench/cpu/MemWrite
add wave -noupdate /testbench/cpu/ReadData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {719 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
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
WaveRestoreZoom {0 ps} {1490 ps}
