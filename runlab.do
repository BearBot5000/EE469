vlib work

# ALL files relevant to the testbench should be listed here. 
vlog -work work ./top.sv
vlog -work work ./testbench.sv
vlog -work work ./reg_file.sv
vlog -work work ./imem.sv
vlog -work work ./dmem.sv
vlog -work work ./alu.sv
vlog -work work ./fetch.sv
vlog -work work ./decode.sv
vlog -work work ./CondUnit.sv
vlog -work work ./execute.sv
vlog -work work ./memory.sv
vlog -work work ./writeBack.sv

# Note that the name of the testbench module is in this statement. If you're running a testbench with a different name CHANGE IT
vsim -voptargs="+acc" -t 1ps -lib work testbench

do wave.do

view signals
view wave



run -all