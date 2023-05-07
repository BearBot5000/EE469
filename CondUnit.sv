/*---------------------------------------COND UNIT-----------------------------------------------------*
*																									   *
*																									   *
* This control consists of a decoder that will read Register 9 and for each Instruction 		       *
* condition determine if the Branch function is allowed based on if it meets the condition statement   *
*																									   *
*------------------------------------------------------------------------------------------------------*/
/*

*/

module CondUnit(
    input  logic        clk, rst,
    input  logic [3:0]  CondE,
    input  logic [3:0]  FlagsE,
    input  logic [3:0]  WA3E,
    input  logic [3:0]  ALUFlagsE,
    input  logic        FlagWriteE,
    output logic [3:0]  Flags,
    output logic        CondExe
);

    logic [3:0] ReadFlag;

    assign Flags = ALUFlagsE;

    //this register stores any ALU flags to be used by future instructions
	 // to see if it meets conditional statements
	 reg_file FlagsReg (
			  .clk       (clk), 
			  .wr_en     (FlagWriteE),
			  .write_data(ALUFlagsE),
			  .write_addr(WA3E),
			  .read_addr1('b1001), 
			  .read_data1(ReadFlag)
	 );


    always_comb begin  
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