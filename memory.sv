//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
Memory Module reads in and writes to the data memory (dmem)
*/

module memory(
    input  logic        clk, rst,
	 input  logic        MemWriteM,
    input  logic [31:0] ALUResultM,
    input  logic [31:0] WriteDataM,
    output logic [31:0] ReadDataM
);

 

    //64 word x 32 bit per word memory.
    dmem dmemory (
        .clk     (clk        ), 
        .wr_en   (MemWriteM  ),
        .addr    (ALUResultM ),
        .wr_data (WriteDataM ),
        .rd_data (ReadDataM  )
    );
endmodule