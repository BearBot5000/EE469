//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
The Hazard Unit module determines if the action being executed 
will result in data hazards (register value not written to register file)
or control hazards (next instruction not decided yet created by a branch operation)
If the action will result in one of these hazards it will create control signals 
to select the correct source of data, stall further operations, or delete the instructions
of actions not required to be performed
*/

module HazardUnit (
    input  logic        clk, rst,
    input  logic        RegWriteM, RegWriteW, MemtoRegE, PCSrcD, 
	 input  logic        PCSrcE, PCSrcM, PCSrcW, BranchTakenE,
    input  logic [3:0]  WA3M, WA3W, WA3E, RA1E, RA2E, RA1D, RA2D,
    output logic [1:0]  ForwardAE, ForwardBE,
    output logic        StallF, StallD, FlushE, FlushD
);

    // Declare local signals for matching and stalling conditions
    logic Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W, Match_12D_E, ldrstallD, PCWrPendingF;

    // Combinational block for matching logic
    always_comb begin

        // Check if RA1E matches WA3M
        if (RA1E == WA3M)  Match_1E_M = 1;
        else               Match_1E_M = 0;

        // Check if RA2E matches WA3M
        if (RA2E == WA3M)  Match_2E_M = 1;
        else               Match_2E_M = 0;

        // Check if RA1E matches WA3W
        if (RA1E == WA3W)  Match_1E_W = 1;
        else               Match_1E_W = 0;

        // Check if RA2E matches WA3W
        if (RA2E == WA3W)  Match_2E_W = 1;
        else               Match_2E_W = 0;

        // Check if both RA1D and RA2D match WA3E
        if ((RA1D == WA3E) | (RA2D == WA3E))  Match_12D_E = 1;
        else                                   Match_12D_E = 0;

        // Control stalling logic based on the state of PCSrc signals
        if (PCSrcD || PCSrcE || PCSrcM)  PCWrPendingF = 1;
        else                              PCWrPendingF = 0;

    end

    // Combinational block for data forwarding and stalling logic
    always_comb begin

        // Data forwarding logic for SRCA mux in the execute stage
        if      (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
        else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
        else                             ForwardAE = 2'b00;

        // Data forwarding logic for SrcB mux in the execute stage
        if      (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
        else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
        else                             ForwardBE = 2'b00;

        // Stalling logic control based on the state of Match_12D_E and MemtoRegE
        if      (Match_12D_E & MemtoRegE) ldrstallD = 1;
        else                              ldrstallD = 0;

    end

    // Generate control signals for stalling and flushing based on the ldrstall signal
    always_comb begin

		
        StallF = (ldrstallD | PCWrPendingF); // Control signal for stalling fetch stage
        StallD = ldrstallD; // Control signal for stalling decode stage
        FlushD = (PCWrPendingF |PCSrcW | BranchTakenE);
		  FlushE = (ldrstallD | BranchTakenE); 

		
	end
		
endmodule
