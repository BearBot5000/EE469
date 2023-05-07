//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
 Fetch module is responsible for fetching instructions from memory and updating
 the program counter appropriately based on branch instructions and
 other control signals. It takes in various inputs related to instruction 
 fetching and outputs the next instruction address (PCPlus4F) and the
 fetched instruction (InstrF).
*/

module fetch(
    input  logic clk, rst,
    input  logic BranchTakenE,
    input  logic [31:0] ResultW,
    input  logic PCSrcW,
    input  logic [31:0] ALUResultE,
	 input  logic StallF,
    output logic [31:0] PCPlus8D,
    output logic [31:0] InstrF
);

	 // PCF is the current program counter
    // PCPrime is the next program counter based on control signals and instruction execution
    logic [31:0] PCF, PCPrime, PCPrimefirst, PCPlus4F;

	 //Instantiate an instruction memory module to fetch instructions from memory
	 imem imemory (
	 .addr  (PCF   ),
	 .instr (InstrF)
	 );
	 
	 //add 4 to PCF for accurate program counting
	 assign PCPlus4F = PCF + 'd4;

	 assign PCPlus8D = PCF + 'd8;
	 //muxes determining PC value passed to PCPrime based off of control signals
    always_comb begin
			if (PCSrcW) begin
				PCPrimefirst =ResultW;
			end else begin
				PCPrimefirst = PCPlus4F;
			end
		
			if (BranchTakenE) begin
				PCPrime = ALUResultE;
			end else begin
				PCPrime = PCPrimefirst;
			end
	end 
	
	 //update PCF to PCPrime unless hazard unit stalls the action
    always_ff @(posedge clk) begin
        if (rst) begin
            PCF   <= 'd0;         
        end else if(~StallF) begin  
            PCF   <= PCPrime;
        end
    end

endmodule