
//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
 Top implements a pipelined 5-stage MIPS processor with hazard detection 
 and forwarding units. The five stages are Fetch, Decode, Execute, Memory,
 and Writeback defined by several modules to implement each of these stages.
 as well as pipeline registers for storing data between stages.
 Additionally, the code includes a hazard detection unit
 and forwarding logic to manage data dependencies between stages. The top-level
 module connects all of these components together and interfaces with the clock
 and reset signals. This code is intended to run on an FPGA or ASIC to execute
 MIPS instructions.


// clk - system clock
// rst - system reset. Technically unnecessary

*/
module top(
    input logic clk, rst
);




//Instantiate the logic for the pipeline registers: FETCH_DECODE, DECODE_EXECUTE
//EXECUTE_MEMORY, MEMORY_WRITEBACK; the HAZARDUNIT, as well as the transfer of data 
//and control signals between stages required for operation

/*---------------------------Fetch Register-----------------------------------*/
    logic [31:0] InstrF;
    logic [31:0] PCPlus8D;

/*--------------------------Decode Register-----------------------------------*/
    logic PCSrcD, RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, FlagWriteD, BranchD, RegWriteWD;
    logic [1:0 ] ALUControlD;
    logic [31:0] ExtImmD, RD1D, RD2D, InstrD;
    logic [3:0 ] WA3D, RA1D, RA2D, CondD;

/*---------------------------Execute Register---------------------------------*/
    logic PCSrcE, RegWriteE, MemtoRegE, MemWriteE, BranchTaken;
	 logic PCSrcEin, RegWriteEin, MemtoRegEin, MemWriteEin, ALUSrcE, BranchE, FlagWriteE;
    logic [31:0] ALUResultE, WriteDataE, ExtImmE, RD1E, RD2E, PCPlus8E;
    logic [3:0 ] WA3E, FlagsE, FlagsOut,  CondE, RA1E, RA2E;
    logic [1:0 ] ALUControlE;
    

/*---------------------------Memory Register----------------------------------*/
    logic PCSrcM, RegWriteM, MemtoRegM, MemWriteM;
    logic [31:0] ALUOutM, ReadDataM, WriteDataM;
    logic [3:0 ] WA3M;

/*---------------------------WriteBack Register-------------------------------*/
    logic RegWriteW, PCSrcW, MemtoRegW;
	 logic [31:0] ResultW, ReadDataW, ALUOutW;
    logic [3:0 ] WA3W;


/*---------------------------Hazard Unit--------------------------------------*/
    logic StallF, StallD, FlushD, FlushE;
	 logic Match_1E_M, Match_2E_M, Match_1E_W, Match_12D_E, ldrStall, PCWrPendingF;
    logic [1:0 ] ForwardAE, ForwardBE;
    

    

    
    //geth the instruction from imem and determines th PC address
    fetch get(
        .clk         (clk        ), 
        .rst         (rst        ),
        .BranchTakenE(BranchTaken), //input from EXECUTE STAGE (if Condexe && BranchE) to determine PCPlus4F source; ALUResultE if true else PCPLus8D
        .ResultW     (ResultW    ), //input from WRITEBACK STAGE (either ALUOutW or ReadDataW) for PC; ResultW if PCSrcW true
        .PCSrcW      (PCSrcW     ), //input from WRITEBACK STAGE to determine PCPlus4F source
        .ALUResultE  (ALUResultE ), //input from EXECUTE STAGE for PCPlus4F source
		  .StallF      (StallF     ), //input from HAZARDUNIT	 to stop PCF from updating due to stall
        .PCPlus8D    (PCPlus8D   ), //output to EXECUTE STAGE to R15
        .InstrF      (InstrF     )  //output to EXECUTE STAGE to InstrD 
    );
	 
	 
		// Pipeline registers for Fetch-Decode stage
		// ensures Decode happens on the 2nd half of clock cycle
		always @(negedge clk) begin
			 //clears the data held by the pipeline register if FlushD true
			 //true if PCWrPendingF, PC is written in writeback, a branch is taken, or reset
			 if (rst | FlushD) begin 
			 
				  InstrD  <= 'd0;
				  
			 //Will stall the transfer of data between Fetch-Decode if ldrStallD true
			 //i.e. LDR in execute stage and (RA1D or RA2D) == WA3E 
			 end else if (~StallD) begin 
			 
				  InstrD  <= InstrF;
				  
			 end
		end
		
		

    //decodes the instructions and breaks it down into various control signals
	 //and addresses to be used by the register file and other modules
    //reads and writes data to and from the register file
    decode control(
        .clk         (clk        ), 
        .rst         (rst        ),
        .InstrD      (InstrD     ), //input from FETCH STAGE containing the instructions to be decoded
        .WA3W        (WA3W       ), //input from WRITEBACK STAGE with the Write Address for ResultW to be stored in Register File
        .ResultW     (ResultW    ), //input from WRITEBACK STAGE of ResultW to be stored in Register File if Write enabled from RegWriteW
        .RegWriteW   (RegWriteW  ), //input from WRITEBACK STAGE to enable ResultW to be stored in Register File 
		  .PCPlus8D    (PCPlus8D   ), //input from FETCH STAGE  for R15 value to register file
        .PCSrcD      (PCSrcD     ), //output from decoded instruction (InstrD) to PCSrcE in EXECUTE STAGE
        .RegWriteD   (RegWriteD  ), //output from decoded instruction (InstrD) to RegWriteE EXECUTE STAGE
        .MemtoRegD   (MemtoRegD  ), //output from decoded instruction (InstrD) to MemtoRegE EXECUTE STAGE
        .MemWriteD   (MemWriteD  ), //output from decoded instruction (InstrD) to MemWriteE EXECUTE STAGE
        .ALUSrcD     (ALUSrcD    ), //output from decoded instruction (InstrD) to ALUSrcE EXECUTE STAGE
        .FlagWriteD  (FlagWriteD ), //output from decoded instruction (InstrD) to FlagWriteE EXECUTE STAGE
        .BranchD     (BranchD    ), //output from decoded instruction (InstrD) to BranchE EXECUTE STAGE 
        .ALUControlD (ALUControlD), //output from decoded instruction (InstrD) to ALUControlE EXECUTE STAGE
        .ExtImmD     (ExtImmD    ), //output the extend (# value instead of register) to ExtImmE in EXECUTE STAGE
        .RA1D        (RA1D       ), //output from decoded instruction (InstrD) to EXECUTE STAGE and HAZARD UNIT
        .RA2D        (RA2D       ), //output from decoded instruction (InstrD) to EXECUTE STAGE and HAZARD UNIT
        .RD1D        (RD1D       ), //output from data read form Register fiile to EXECUTE STAGE and HAZARD UNIT
        .RD2D        (RD2D       ), //output from data read form Register fiile to EXECUTE STAGE and HAZARD UNIT
        .WA3D        (WA3D       ), //output the write address from the decoded instruction (InstrD) to WA3E in EXECUTE STAGE
        .CondD       (CondD      )  //output the determined condition from decoded instruction to EXECUTE STAGE
        );
		  
		// Pipeline registers for DECODE-EXECUTE stage
		always @(posedge clk) begin
			 //clears the data held by the pipeline register if FlushE true(when a branch is taken) or reset
			 if (rst | FlushE) begin  
				  PCSrcEin 		<= 'd0;
				  RegWriteEin  <= 'd0;
				  MemtoRegE		<= 'd0;
				  MemWriteEin  <= 'd0;
				  ALUSrcE      <= 'd0;
				  BranchE      <= 'd0;
				  FlagWriteE   <= 'd0;
				  ALUControlE  <= 'd0;
				  ExtImmE      <= 'd0;
				  RA1E         <= 'd0;
				  RA2E         <= 'd0;
              RD1E         <= 'd0;
				  RD2E         <= 'd0;
				  CondE        <= 'd0;
				  FlagsE       <= 'd0;
				  WA3E         <= 'd0;  
			 end else begin
				  PCSrcEin     <= PCSrcD ;
				  RegWriteEin  <= RegWriteD;
				  MemtoRegE    <= MemtoRegD;
				  MemWriteEin  <= MemWriteD;
				  ALUSrcE      <= ALUSrcD; 
				  BranchE      <= BranchD;
				  FlagWriteE   <= FlagWriteD;
				  ALUControlE  <= ALUControlD;
				  ExtImmE      <= ExtImmD;
				  RA1E         <= RA1D;
				  RA2E         <= RA2D;
              RD1E         <= RD1D;
				  RD2E         <= RD2D;
				  CondE        <= CondD;
				  FlagsE       <= FlagsOut;
				  WA3E         <= WA3D;
			 end
		end
		
	//HazardUnit takes in various control signals and data to create control signals
	//used by registers and muxes to ensure data and control hazards are managed
	// and the pipeline register will function correctly
	HazardUnit precarius(
		   .clk         (clk        ), 
         .rst         (rst        ),
			.RegWriteM 	 (RegWriteM  ), //input from MEMORY for control hazard logic for determining SRCA and SRCB 
			.RegWriteW   (RegWriteW  ), //input from MEMORY for control hazard logic for determining SRCA and SRCB
			.MemtoRegE   (MemtoRegE  ), //input from EXECUTE for control hazard logic for determining stalling logic (stallD/stallF)
			.PCSrcD      (PCSrcD     ), //input from DECODE for control hazard logic for determining stalling and flush logic (StallF/FlushD)
			.PCSrcE      (PCSrcE     ), //input from EXECUTE for control hazard logic for determining stalling logic (StallF/FlushD)
			.PCSrcM      (PCSrcM     ), //input from MEMORY for control hazard logic for determining stalling logic ((StallF/FlushD)
			.PCSrcW      (PCSrcW     ), //input from WRIteBack for control hazard logic for determining stalling logic (StallF/FlushD)
			.BranchTakenE(BranchTaken), //input from EXECUTE for control hazard logic if Branck taken to clear fetch_DECODE pipeline register
			.WA3M 		 (WA3M       ), //input from MEMORY for control hazard logic for determining SRCA and SRCB
			.WA3W 		 (WA3W       ), //input from WRITEBACK for control hazard logic for determining SRCA and SRCB
			.WA3E 		 (WA3E		 ), //input from MEMORY for control hazard logic for determining stalling logic
			.RA1E 		 (RA1E		 ), //input from EXECUTE for control hazard logic for determining SRCA and SRCB
			.RA2E 	    (RA2E		 ), //input from EXECUTE for control hazard logic for determining SRCA and SRCB
			.RA1D 		 (RA1D		 ), //input from EXECUTE for control hazard logic for determining stalling logic (stallD)
			.RA2D 		 (RA2D		 ), //input from EXECUTE for control hazard logic for determining stalling logic (stallD)
			.ForwardAE   (ForwardAE  ), //input from EXECUTE for control hazard logic for determining SRCA and SRCB
			.ForwardBE   (ForwardBE  ), //input from EXECUTE for control hazard logic for determining SRCA and SRCB
			.StallF		 (StallF		 ), //output to program counter to stall update of PCF
			.StallD		 (StallD		 ), //output to FETCH-DECODE pipel;ine register to stall data forwarding 
			.FlushE		 (FlushE		 ), //output to DECODE-EXECUTE pipeline register to clr stored data
			.FlushD		 (FlushD		 )  //output to FETCH-DECODE pipeline register to clr stored data
);


    //performs the ALU operations and performs logical operations to determien and pass on various control signals to different stages
    execute french(
        .clk         (clk        ), 
        .rst         (rst        ),
        .PCSrcE      (PCSrcEin   ), //input from DECODE STAGE control signal
        .RegWriteE   (RegWriteEin), //input from DECODE STAGE control signal
        .MemWriteE   (MemWriteEin), //input from DECODE STAGE control signal
        .ALUSrcE     (ALUSrcE    ), //input from DECODE STAGE control signal to control the sources being sent to ALU
        .BranchE     (BranchE    ), //input from DECODE STAGE control signal to indicate a branch taken operation
		  .FlagWriteE  (FlagWriteE ), //input from DECODE STAGE Flag write signal to enable the flags to be stored in the flag reg
        .ALUControlE (ALUControlE), //input from DECODE STAGE control signal to control the ALU operation
        .ExtImmE     (ExtImmE    ), //input from DECODE STAGE with extended immediate # if applicable
        .RD1E        (RD1E       ), //input from DECODE STAGE
        .RD2E        (RD2E       ), //input from DECODE STAGE
		  .CondE       (CondE      ), //input from DECODE STAGE to indicate a condition from the instruction
		  .FlagsE      (FlagsE     ), //input from the flags generated by the CondUnit from ALU Flags
		  .ForwardAE   (ForwardAE  ), //input control signal from HazardUnit to mux to determine the input data to SrcA
		  .ForwardBE   (ForwardBE  ), //input control signal from HazardUnit to mux to determine the input data to SrcB
		  .ResultW     (ResultW    ), //input for SrcA and SrcB muxes from WriteBack  
		  .ALUOutM     (ALUOutM    ), //input for SrcA and SrcB muxes from MEMORY
        .PCSrcEout   (PCSrcE     ), //output control signal to MEMORY STAGE; True if (PCSrcE && CondExe)
        .RegWriteEout(RegWriteE  ), //output control signal to MEMORY STAGE; True if (RegWriteE && CondExe)
        .MemWriteEout(MemWriteE  ), //output control signal to MEMORY STAGE; True if (MemWriteE && CondExe)
        .BranchTakenE(BranchTaken), //output control signal to FETCH STAGE to determine PC Address selected; True if (BranchE && CondExe)
        .ALUResultE  (ALUResultE ), //output the ALU Result to MEMORY STAGE for storage or passed onto Register File and to FETCH STAGE for PC Address
        .WriteDataE  (WriteDataE ), //output the write data to MEMORY STAGE to be stored in Data Memory if applicable
        .FlagsOut    (FlagsOut   )  //output to MEMORY STAGE the write address for the current operation
    );
		
	 
		// Pipeline registers for Decode-Memory stage
		always @(posedge clk) begin
			 if (rst) begin
				PCSrcM     <= 'd0;      
				RegWriteM  <= 'd0;   
				MemtoRegM  <= 'd0;   
				MemWriteM  <= 'd0;   
				ALUOutM    <= 'd0;  
				WriteDataM <= 'd0;  
				WA3M       <= 'd0; 
			 
			 end else begin
				PCSrcM <= PCSrcE;     
				RegWriteM  <= RegWriteE;  
				MemtoRegM  <= MemtoRegE; 
				MemWriteM  <= MemWriteE;  
				ALUOutM    <= ALUResultE; 
				WriteDataM <= WriteDataE;
				WA3M       <= WA3E;
			 end
		end
		
		
			 

    //will read from and store to data memory (DMEM)and pass on various control signals
    memory store(
        .clk         (clk        ), 
        .rst         (rst        ),
        .MemWriteM   (MemWriteM  ), //input from EXECUTE STAGE to write enable Data Memory storage in dmem if true
        .ALUResultM  (ALUOutM    ), //input from EXECUTE STAGE ALU of address sent to Data Memory if MemWriteM true, else passed on to WRITEBACK STAGE
        .WriteDataM  (WriteDataM ), //input from EXECUTE STAGE of the data from SRCB form Register File to be written in Data Memory
        .ReadDataM   (ReadDataM  )  //output to WRITEBACK STAGE the read data from Data memory if applicable
    );
	 
		// Pipeline registers for Memory-Writeback stage
		always @(posedge clk) begin
			 if (rst) begin
				PCSrcW    <= 'd0;
				RegWriteW <= 'd0;
				MemtoRegW <= 'd0;
				ReadDataW <= 'd0;
				ALUOutW   <= 'd0;
				RegWriteW <= 'd0;
				WA3W      <= 'd0;
			  
			 end else begin
				PCSrcW    <= PCSrcM;
				RegWriteW <= RegWriteM;
				MemtoRegW <= MemtoRegM;
				ReadDataW <= ReadDataM;
				ALUOutW   <= ALUOutM;
				RegWriteW <= RegWriteM;
				WA3W      <= WA3M;
			 end
		end
		

    //will determine the result value chosen to be sent to other stages and pass on various control signals
    writeBack loopback(
        .clk         (clk        ), 
        .rst         (rst        ), 
        .MemtoRegW   (MemtoRegW  ), //input control signal from MEMORY STAGE selecting if ReadDataW or ALUOutW becomes ResultW (ReadDataW if true)
        .ReadDataW   (ReadDataW  ), //input read data from Data Memory in MEMORY STAGE if applicable
        .ALUOutW     (ALUOutW    ), //input ALUOut value from MEMORY STAGE if applicable
        .ResultW     (ResultW    )  //output the ReadDataW or ALUOutW depending on MemtoRegW value sent to DECODE STAGE as Write Data of Register File
												//additionally sent to FETCH STAGE for PC value if PCSrcW true
    );

endmodule