//Brenton Mizell
//Rohan Menon
// 5/5/2023
// EE 469
// Lab#3, Task 1
/*
DECODE module performs the 3 major functions of 
 1.Decoding the instructions to determine PC Function
 2. Storing data into the register file
 3. reading data from the Register File. 
 The Decode module will run on the 2nd half of the clock cycle ensuring a streamlined operation 
*/


module decode(
    input  logic        clk, rst,
    input  logic [31:0] InstrD,
    input  logic [3:0 ] WA3W,
    input  logic [31:0] ResultW,
    input  logic        RegWriteW,
	 input  logic [31:0] PCPlus8D,
    output logic        PCSrcD, RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, FlagWriteD, BranchD,
    output logic [1:0 ] ALUControlD,
    output logic [31:0] ExtImmD,RD1D, RD2D,
    output logic [3:0 ] WA3D, RA1D, RA2D,
    output logic [3:0 ] CondD
);

    logic [1:0 ] RegSrcD, ImmSrcD;
    
    // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1D = RegSrcD[0] ? 4'd15        : InstrD[19:16];
    assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[ 3: 0];


    assign WA3D = InstrD[15:12];
    assign CondD = InstrD[31:28];
	 
	 // Since R15 is implemented separately, we have to
	 // do some logic before we can output RD1D and RD2D
	 // Specifically we check if we're looking for R15 and
	 // ouput the PCPlus8D if so.
	 logic [31:0] RD1DPrelim, RD2DPrelim;
	 assign RD1D = (RA1D == 'd15) ? PCPlus8D : RD1DPrelim;
	 assign RD2D = (RA2D == 'd15) ? PCPlus8D : RD2DPrelim;

	 //store and read data from register file
    reg_file u_reg_file (
        .clk       (~clk), 
        .wr_en     (RegWriteW),
        .write_data(ResultW),
        .write_addr(WA3W),
        .read_addr1(RA1D), 
        .read_addr2(RA2D),
        .read_data1(RD1DPrelim), 
        .read_data2(RD2DPrelim)
    );
	 
    
    // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_comb begin
        if      (ImmSrcD == 'b00) ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
        else if (ImmSrcD == 'b01) ExtImmD = {20'b0, InstrD[11:0]};                 // 12 bit immediate - mem operations
        else                     ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
    end

    
    
    
    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
    
    always_comb begin
        casez (InstrD[27:20])

            // ADD (Imm or Reg internal to module)
            8'b00?_0100_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrcD    = 0;
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b00;
				FlagWriteD = 0;
                BranchD = 0;
            end

            // SUB (Imm or Reg)
            8'b00?_0010_0 : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b01;
				FlagWriteD = 0;
                BranchD = 0;
            end

            // AND
            8'b000_0000_0 : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b10;  
				FlagWriteD = 0;
                BranchD = 0;
            end

            // ORR
            8'b000_1100_0 : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b11;
				FlagWriteD = 0;
                BranchD = 0;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrcD    = 0; 
                MemtoRegD = 1; 
                MemWriteD = 0; 
                ALUSrcD   = 1;
                RegWriteD = 1;
                RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
				FlagWriteD = 0;
                BranchD = 0;
            end

            // STR
            8'b010_1100_0 : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; // doesn't matter
                MemWriteD = 1; 
                ALUSrcD   = 1;
                RegWriteD = 0;
                RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
				FlagWriteD = 0;
                BranchD = 0;
            end

            
				//If the conditional statement is met or no condition will allow 
				
				// B
            8'b1010_???? : begin
                PCSrcD    = 1; 
                MemtoRegD = 0;
                MemWriteD = 0; 
                ALUSrcD   = 1;
                RegWriteD = 0;
                RegSrcD   = 'b01;
                ImmSrcD   = 'b10; 
                ALUControlD = 'b00;  // do an add
                FlagWriteD = 0;
                BranchD = 1;
			end
				
				
           
				/*if the compare function is called will compare by subtraction
					and place the Result in the u_regs_file and the flags if any in the 
					FlagsReg*/
					
				//CMP
				8'b???_0010_1 :   begin
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b01; //compareALU  by subtraction
                FlagWriteD = 1;//write enable to write flag result to FlagsReg
                BranchD = 0;
            end
				

            default: begin
                    PCSrcD    = 0; 
                    MemtoRegD = 0; // doesn't matter
                    MemWriteD = 0; 
                    ALUSrcD   = 0;
                    RegWriteD = 0;
                    RegSrcD   = 'b00;
                    ImmSrcD   = 'b00; 
                    ALUControlD = 'b00;  // do an add
                    
                    // set the defaults for the condition check
                    FlagWriteD = 0;
                    BranchD = 0;
                            
            end
        endcase
    end
endmodule