// Brenton Mizell 
// Rohan Menon
// 4/7/2023
// EE 469
// Lab#1, Task 3

/*alu takes two 32-bit values in and can perform addition, subtraction, ANDing, and ORing of the values 
into a 32 bit result which is outputted. The arithmetic logic unit will flag if there resulting 32 bit
value is negative (4'b1000), zero (4'b0100), has a carry-out (4'b0010), an overflow(4'b0001), or any combination 
of these flags.*/


module alu(a,b,ALUControl,Result,ALUFlags);
  input logic [31:0] a;
  input logic [31:0] b;
  input logic [1:0] ALUControl;
  output logic [31:0] Result;
  output logic [3:0] ALUFlags;
  
	//reg karry creates a 33 bit calue to check for carryover

	reg [32:0] karry;

	//executes the case(ALUControl) anytime the ALUControl value changes
  always@(ALUControl, a, b) begin
    case(ALUControl)
      
		//addition
		2'b00: begin Result = a + b;
						 karry  = a + b; 
				 end
		  
		//subtraction
      2'b01: Result = a - b;
			
		//ANDing
      2'b10: Result = a & b;
       
		//ORing
      2'b11: Result = a | b;
   
		
    endcase
	 
	 

	 ALUFlags[3] = (Result[31]) ? 1:0;//negative flag
	 
	 ALUFlags[2] = (Result == 32'b0) ? 1:0;//zero flag
	 
	 ALUFlags[1] = (~ALUControl[1] && (karry[32] | (ALUControl[0] && ~(a^b)))) ? 1:0;//carry-over flag
	 
	 ALUFlags[0] = (~(ALUControl[0] ^ a[31] ^ b[31]) && (a[31] & Result[31]) && (~ALUControl[1])) ? 1:0;//overflow flag
  
  end
endmodule

