/* arm is the spotlight of the show and contains the bulk of the datapath and control logic. This module is split into two parts, the datapath and control. 
*/

// clk - system clock
// rst - system reset
// Instr - incoming 32 bit instruction from imem, contains opcode, condition, addresses and or immediates
// ReadData - data read out of the dmem
// WriteData - data to be written to the dmem
// MemWrite - write enable to allowed WriteData to overwrite an existing dmem word
// PC - the current program count value, goes to imem to fetch instruciton
// ALUResult - result of the ALU operation, sent as address to the dmem

module arm (
    input  logic        clk, rst,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic [31:0] WriteData, 
    output logic [31:0] PC, ALUResult,
    output logic        MemWrite
);

    // datapath buses and signals
    logic [31:0] PCPrime, PCPlus4, PCPlus8; // pc signals
    logic [ 3:0] RA1, RA2;                  // regfile input addresses
    logic [31:0] RD1, RD2;                  // raw regfile outputs
    logic [ 3:0] ALUFlags;                  // alu combinational flag outputs
    logic [31:0] ExtImm, SrcA, SrcB;        // immediate and alu inputs 
    logic [31:0] Result;                    // computed or fetched value to be written into regfile or pc
	 
	 logic [31:0] ReadFlag1, ReadFlag2;		  //raw Flags_reg outputs
	 logic [ 3:0] FlagAddr1, FlagAddr2;		  //FlagsReg addresses
	 

    // control signals
    logic PCSrc, MemtoReg, ALUSrc, RegWrite;
    logic [1:0] RegSrc, ImmSrc, ALUControl;
	 
	 
	 //control signal for conditional statement ALUControl
	 logic [1:0] CMPRControl;
	 //control signal for to trigger the FlagRegister to store the flag
	 logic FlagWrite;
	 //If true will permit B operation If false will not 
	 logic B_Allow;


    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words to pass forward and operate on. It is 
    ** noticeably missing the register file and alu, which you will fill in using the modules made in lab 1. To correctly match up signals to the 
    ** ports of the register file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------


    assign PCPrime = PCSrc ? Result : PCPlus4;  // mux, use either default or newly computed value
    assign PCPlus4 = PC + 'd4;                  // default value to access next instruction
    assign PCPlus8 = PCPlus4 + 'd4;             // value read when reading from reg[15]

    // update the PC, at rst initialize to 0
    always_ff @(posedge clk) begin
        if (rst) PC <= '0;
        else     PC <= PCPrime;
    end

    // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1 = RegSrc[0] ? 4'd15        : Instr[19:16];
    assign RA2 = RegSrc[1] ? Instr[15:12] : Instr[ 3: 0];

    /*reg_file operates as a primary operational memory device. It defines a 16x32 register file with
		two read ports, one write port and is asynchronous. By setting either of the read address vectors
		(read_addr1 or read_addr2), stored data will be outputted on the corresponding read data vectors
		(read_data1 or read_data2, respectively). To write data, the wr_en pin is driven high, the write_add
		vector is set to the desired address to store data, and the write_data vector is set to the data value*/
		
		//this register will store and read the ALURESULT
    reg_file u_reg_file (
        .clk       (clk), 
        .wr_en     (RegWrite),
        .write_data(Result),
        .write_addr(Instr[15:12]),
        .read_addr1(RA1), 
        .read_addr2(RA2),
        .read_data1(RD1), 
        .read_data2(RD2)
    );
	 
	 
	 //this register stores any ALU flags to be used by future instructions
	 // to see if it meets conditional statements
	 reg_file FlagsReg (
			  .clk       (clk), 
			  .wr_en     (FlagWrite),
			  .write_data(ALUFlags),
			  .write_addr(Instr[15:12]),
			  .read_addr1('b1001), 
			  //.read_addr2(ReadFlag2),
			  .read_data1(ReadFlag1)
			  //.read_data2(FlagAddr2)
	 );

	 
	 
	 
	 
	 

    // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_comb begin
        if      (ImmSrc == 'b00) ExtImm = {{24{Instr[7]}},Instr[7:0]};          // 8 bit immediate - reg operations
        else if (ImmSrc == 'b01) ExtImm = {20'b0, Instr[11:0]};                 // 12 bit immediate - mem operations
        else                     ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; // 24 bit immediate - branch operation
    end

    // WriteData and SrcA are direct outputs of the register file, wheras SrcB is chosen between reg file output and the immediate
    assign WriteData = (RA2 == 'd15) ? PCPlus8 : RD2;           // substitute the 15th regfile register for PC 
    assign SrcA      = (RA1 == 'd15) ? PCPlus8 : RD1;           // substitute the 15th regfile register for PC 
    assign SrcB      = ALUSrc        ? ExtImm  : WriteData;     // determine alu operand to be either from reg file or from immediate

    /*alu takes two 32-bit values from Src A and B and can perform addition, subtraction, ANDing, and ORing of the values 
		into a 32 bit result which is output as a ALUResult. The arithmetic logic unit will flag if there resulting 32 bit
		value is negative (4'b1000), zero (4'b0100), has a carry-out (4'b0010), an overflow(4'b0001), or any combination 
		of these flags.*/
    alu u_alu (
        .a          (SrcA), 
        .b          (SrcB),
        .ALUControl (ALUControl),
        .Result     (ALUResult),
        .ALUFlags   (ALUFlags)
    );
	 
	 
	 

    // determine the result to run back to PC or the register file based on whether we used a memory instruction
    assign Result = MemtoReg ? ReadData : ALUResult;    // determine whether final writeback result is from dmemory or alu


    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
    
    always_comb begin
        casez (Instr[27:20])

            // ADD (Imm or Reg)
            8'b00?_0100_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrc    = 0;
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b00;
					 FlagWrite = 0;
            end

            // SUB (Imm or Reg)
            8'b00?_0010_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                ALUControl = 'b01;
					 FlagWrite = 0;
            end

            // AND
            8'b000_0000_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b10;  
					 FlagWrite = 0;
            end

            // ORR
            8'b000_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = 0; 
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00;    // doesn't matter
                ALUControl = 'b11;
					 FlagWrite = 0;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrc    = 0; 
                MemtoReg = 1; 
                MemWrite = 0; 
                ALUSrc   = 1;
                RegWrite = 1;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 0;
            end

            // STR
            8'b010_1100_0 : begin
                PCSrc    = 0; 
                MemtoReg = 0; // doesn't matter
                MemWrite = 1; 
                ALUSrc   = 1;
                RegWrite = 0;
                RegSrc   = 'b10;    // msb doesn't matter
                ImmSrc   = 'b01; 
                ALUControl = 'b00;  // do an add
					 FlagWrite = 0;
            end

            
				//If the conditional statement is met or no condition will allow 
				
				// B
            8'b1010_???? : begin
					if (B_Allow == 1) begin
								PCSrc    = 1; 
								MemtoReg = 0;
								MemWrite = 0; 
								ALUSrc   = 1;
								RegWrite = 0;
								RegSrc   = 'b01;
								ImmSrc   = 'b10; 
								ALUControl = 'b00;  // do an add
								FlagWrite = 0;
					end
					
					else begin
							  PCSrc    = 0; 
							  MemtoReg = 0; // doesn't matter
							  MemWrite = 0; 
							  ALUSrc   = 0;
							  RegWrite = 0;
							  RegSrc   = 'b00;
							  ImmSrc   = 'b00; 
							  ALUControl = 'b00;  // do an add
							  FlagWrite = 0;
					end
				end
				
				
           
				/*if the compare function is called will compare by subtraction
					and place the Result in the u_regs_file and the flags if any in the 
					FlagsReg*/
					
				//CMP
				8'b???_0010_1 :   begin
                PCSrc    = 0; 
                MemtoReg = 0; 
                MemWrite = 0; 
                ALUSrc   = Instr[25]; // may use immediate
                RegWrite = 1;
                RegSrc   = 'b00;
                ImmSrc   = 'b00; 
                
                ALUControl = 'b01; //compareALU  by subtraction
                FlagWrite = 1;//write enable to write flag result to FlagsReg
            end
				

				default: begin
					  PCSrc    = 0; 
					  MemtoReg = 0; // doesn't matter
					  MemWrite = 0; 
					  ALUSrc   = 0;
					  RegWrite = 0;
					  RegSrc   = 'b00;
					  ImmSrc   = 'b00; 
					  ALUControl = 'b00;  // do an add
					  
					  // set the defaults for the condition check
					  FlagWrite = 0;
							  
				end
        endcase
    end
	 
	/*---------------------------------------B CONTROL-----------------------------------------------------*
	 *																																		 *
	 *																																		 *
	 * This control consists of a decoder that will read Register 9 and for each Instruction 					 *
	 * condition determine if the Branch function is allowed based on if it meets the condition statement  *
    *																																		 *
	 *-----------------------------------------------------------------------------------------------------*/
	
		always_comb begin  
			 casez (Instr[31:28])
				  4'b1110 : B_Allow = 1;

				  //Equal
				  4'b0000 : if (ReadFlag1[3:2] == 'b01) B_Allow = 1; else B_Allow = 0; // 0 flag
				 

				  //Not Equal
				  4'b0001 : if (ReadFlag1[3:2] == 'b00|| ReadFlag1[3:2] == 'b10) B_Allow = 1; else B_Allow = 0; //not 0 flag


				  //Greater or Equal
				  4'b1010 : if (ReadFlag1[3:2] == 'b00 || ReadFlag1[3:2] == 'b01) B_Allow = 1; else B_Allow = 0; // 0 flag/no flag/carry flag/overflow flag      
				
				  //Greater
				  4'b1100 : if (ReadFlag1[3:2] == 'b00) B_Allow = 1; else B_Allow = 0;//no flag/carry flag/overflow flag        
				  

				  //Less or Equal
				  4'b1101 : if (ReadFlag1[3:2] == 'b10 || ReadFlag1[3:2] == 'b01) B_Allow = 1; else B_Allow = 0;//negative flag/0 flag/carry flag/overflow flag        
				  

				  //Less
				  4'b1011 : if (ReadFlag1 == 'b10) B_Allow = 1; else B_Allow = 0;//negative flag/carry flag/overflow flag             
				  
				  
				  default: B_Allow = 0;
				  
			 endcase
		end


endmodule