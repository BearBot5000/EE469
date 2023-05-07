//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
The execute module determines if conditions are met to execute the instructions given
and prevent the instructions from being carried out if not met by updating control signals.
It determines which conditions are required and if they are met byt checking for flags which are
determined by the ALU and stored in the flag register.

It controls the data being fed into the ALU through Source muxes

Additionally the execute module will perform the instructed ALU action and pass on the result
*/


module execute(
    input  logic        clk, rst,
    input  logic        PCSrcE, RegWriteE, MemWriteE, ALUSrcE, BranchE,  FlagWriteE,
    input  logic [1:0]  ALUControlE,
    input  logic [31:0] ExtImmE, RD1E, RD2E,
    input  logic [3:0]  CondE, FlagsE,
	 input  logic [1:0]  ForwardAE, ForwardBE,
	 input  logic [31:0] ResultW, ALUOutM,
    output logic        PCSrcEout, RegWriteEout, MemWriteEout, BranchTakenE,
    output logic [31:0] ALUResultE,
    output logic [31:0] WriteDataE,
    output logic [3:0] FlagsOut
);

	 //instantiate logic
    logic [31:0] SrcAE, SrcBE;
    logic CondExe;
	 logic [3:0] ALUFlags;
	 
	 //mux logic to determine if SrcB
	 assign SrcBE = ALUSrcE ? ExtImmE : WriteDataE;
	 
	 
	 always_comb begin
		//mux logic to determine SrcA data source based off of control signal from Hazard Unit
		case (ForwardAE)
			'b01: SrcAE = ResultW;
			'b10: SrcAE = ALUOutM;
			default: SrcAE = RD1E;
		endcase
		
		//mux logic to determine WriteData source based off of control signal from Hazard Unit
		case (ForwardBE)
			'b01: WriteDataE = ResultW;
			'b10: WriteDataE = ALUOutM;
			default: WriteDataE = RD2E;
		endcase
	 end
		
	//conditional logic to determine if control signals being sent to the 
	//memory module meet the condition
	assign PCSrcEout = PCSrcE & CondExe;
	assign RegWriteEout = RegWriteE & CondExe;
	assign MemWriteEout = MemWriteE & CondExe;
	assign BranchTakenE = BranchE & CondExe;
		

  /*alu takes two 32-bit values from Src A and B and can perform addition, subtraction, ANDing, and ORing of the values 
	into a 32 bit result which is output as a ALUResult. The arithmetic logic unit will flag if there resulting 32 bit
	value is negative (4'b1000), zero (4'b0100), has a carry-out (4'b0010), an overflow(4'b0001), or any combination 
	of these flags.*/
    alu u_alu (
        .a          (SrcAE), 
        .b          (SrcBE),
        .ALUControl (ALUControlE),
        .Result     (ALUResultE),
        .ALUFlags   (FlagsOut)
    );

/*------------------------------------Conditional Unit------------------------------------------------------

Reads in the flags from ALU given by same Cond Unit in a previous cycle for conditional checks.  
Can store flags when Write enabled (FlagWriteE true) for current ALU execution (i.e. CMPR)
determines if a condition for the current operation is required (true if CondE true) (i.e. branch commands)

-----------------------------------------------------------------------------------------------------------*/

    //this register stores any ALU flags to be used by future instructions
	 // to see if it meets conditional statements
	/* reg_file FlagsReg (
			  .clk       (clk), 
			  .wr_en     (FlagWriteE),
			  .write_data(ALUFlags),
			  .write_addr('b1001),
			  .read_addr1('b1001), 
			  .read_data1(FlagsOut)
	 );*/


    always_comb begin 
	
				//reads the conditional value and determines if the condition is met by reading the stored
				//flags in the flag register
            casez (CondE)
                4'b1110 : CondExe = 1;

                //Equal
                4'b0000 : if (FlagsE[3:2] == 'b01) CondExe = 1; else CondExe = 0; // 0 flag
                

                //Not Equal
                4'b0001 : if (FlagsE[3:2] == 'b00|| FlagsE[3:2] == 'b10) CondExe = 1; else CondExe = 0; //not 0 flag


                //Greater or Equal
                4'b1010 : if (FlagsE[3:2] == 'b00 || FlagsE[3:2] == 'b01) CondExe = 1; else CondExe = 0; // 0 flag/no flag/carry flag/overflow flag      
            
                //Greater
                4'b1100 : if (FlagsE[3:2] == 'b00) CondExe = 1; else CondExe = 0;//no flag/carry flag/overflow flag        
                

                //Less or Equal
                4'b1101 : if (FlagsE[3:2] == 'b10 || FlagsE[3:2] == 'b01) CondExe = 1; else CondExe = 0;//negative flag/0 flag/carry flag/overflow flag        
                

                //Less
                4'b1011 : if (FlagsE == 'b10) CondExe = 1; else CondExe = 0;//negative flag/carry flag/overflow flag             
                
                
                default: CondExe = 0;
                
            endcase
    end


endmodule