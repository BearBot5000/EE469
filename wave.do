onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/cpu/clk
add wave -noupdate -radix unsigned /testbench/cpu/rst
add wave -noupdate -radix unsigned /testbench/cpu/get/PCF
add wave -noupdate -radix unsigned /testbench/cpu/get/PCPrimefirst
add wave -noupdate -radix unsigned /testbench/cpu/get/PCPrime
add wave -noupdate -radix hexadecimal /testbench/cpu/InstrF
add wave -noupdate -radix hexadecimal /testbench/cpu/InstrD
add wave -noupdate -radix unsigned /testbench/cpu/WA3D
add wave -noupdate -radix unsigned /testbench/cpu/WA3E
add wave -noupdate -radix unsigned /testbench/cpu/WA3M
add wave -noupdate -radix unsigned /testbench/cpu/WA3W
add wave -noupdate -radix unsigned /testbench/cpu/ResultW
add wave -noupdate /testbench/cpu/StallF
add wave -noupdate /testbench/cpu/StallD
add wave -noupdate /testbench/cpu/FlushD
add wave -noupdate /testbench/cpu/FlushE
add wave -noupdate /testbench/cpu/ForwardAE
add wave -noupdate /testbench/cpu/ForwardBE
add wave -noupdate -radix unsigned {/testbench/cpu/control/u_reg_file/memory[9]}
add wave -noupdate -radix unsigned {/testbench/cpu/control/u_reg_file/memory[3]}
add wave -noupdate -radix unsigned {/testbench/cpu/control/u_reg_file/memory[2]}
add wave -noupdate -radix unsigned {/testbench/cpu/control/u_reg_file/memory[1]}
add wave -noupdate -radix unsigned -childformat {{{[31]} -radix unsigned} {{[30]} -radix unsigned} {{[29]} -radix unsigned} {{[28]} -radix unsigned} {{[27]} -radix unsigned} {{[26]} -radix unsigned} {{[25]} -radix unsigned} {{[24]} -radix unsigned} {{[23]} -radix unsigned} {{[22]} -radix unsigned} {{[21]} -radix unsigned} {{[20]} -radix unsigned} {{[19]} -radix unsigned} {{[18]} -radix unsigned} {{[17]} -radix unsigned} {{[16]} -radix unsigned} {{[15]} -radix unsigned} {{[14]} -radix unsigned} {{[13]} -radix unsigned} {{[12]} -radix unsigned} {{[11]} -radix unsigned} {{[10]} -radix unsigned} {{[9]} -radix unsigned} {{[8]} -radix unsigned} {{[7]} -radix unsigned} {{[6]} -radix unsigned} {{[5]} -radix unsigned} {{[4]} -radix unsigned} {{[3]} -radix unsigned} {{[2]} -radix unsigned} {{[1]} -radix unsigned} {{[0]} -radix unsigned}} -subitemconfig {{/testbench/cpu/control/u_reg_file/memory[0][31]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][30]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][29]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][28]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][27]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][26]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][25]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][24]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][23]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][22]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][21]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][20]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][19]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][18]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][17]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][16]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][15]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][14]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][13]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][12]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][11]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][10]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][9]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][8]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][7]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][6]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][5]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][4]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][3]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][2]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][1]} {-radix unsigned} {/testbench/cpu/control/u_reg_file/memory[0][0]} {-radix unsigned}} {/testbench/cpu/control/u_reg_file/memory[0]}
add wave -noupdate /testbench/cpu/control/PCSrcD
add wave -noupdate /testbench/cpu/control/RegWriteD
add wave -noupdate /testbench/cpu/control/MemtoRegD
add wave -noupdate /testbench/cpu/control/MemWriteD
add wave -noupdate /testbench/cpu/control/ALUControlD
add wave -noupdate /testbench/cpu/control/BranchD
add wave -noupdate /testbench/cpu/control/ALUSrcD
add wave -noupdate /testbench/cpu/control/FlagWriteD
add wave -noupdate /testbench/cpu/control/ImmSrcD
add wave -noupdate -radix unsigned /testbench/cpu/control/RA1D
add wave -noupdate -radix unsigned /testbench/cpu/control/RA2D
add wave -noupdate -radix unsigned /testbench/cpu/control/RD1D
add wave -noupdate -radix unsigned /testbench/cpu/control/RD2D
add wave -noupdate -radix unsigned /testbench/cpu/french/SrcAE
add wave -noupdate -radix unsigned /testbench/cpu/french/SrcBE
add wave -noupdate -radix unsigned /testbench/cpu/french/ALUOutM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 282
configure wave -valuecolwidth 53
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
WaveRestoreZoom {0 ps} {2205 ps}
