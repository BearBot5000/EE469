vlib work

# ALL files relevant to the testbench should be listed here. 
vlog -work work ./top.sv

vlog -work work ./arm.sv
vlog -work work ./alu.sv
vlog -work work ./reg_file.sv

vlog -work work ./imem.sv
vlog -work work ./dmem.sv

vlog -work work ./testbench.sv

# Note that the name of the testbench module is in this statement. If you're running a testbench with a different name CHANGE IT
vsim -voptargs="+acc" -t 1ps -lib work testbench

view signals
view wave



run -all