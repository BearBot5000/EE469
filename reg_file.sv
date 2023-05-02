// Brenton Mizell 
// Rohan Menon
// EE 469
// 4/7/2023
// Lab #1, Task 2

/*reg_file operates as a primary operational memory device. It defines a 16x32 register file with
two read ports, one write port and is asynchronous. By setting either of the read address vectors
(read_addr1 or read_addr2), stored data will be outputted on the corresponding read data vectors
(read_data1 or read_data2, respectively). To write data, the wr_en pin is driven high, the write_add
vector is set to the desired address to store data, and the write_data vector is set to the data value*/

module reg_file (clk, wr_en, write_data,write_addr, read_addr1, read_addr2, read_data1, read_data2);
	input logic clk, wr_en;
	input logic [31:0] write_data;
	input logic [3:0] write_addr; 
	input logic [3:0] read_addr1;
	input logic [3:0] read_addr2;
	output logic [31:0] read_data1; 
	output logic [31:0] read_data2;
	 
	// `memory` creates the 16x32 vector of vectors
	// that store data added to the register file
	logic [15:0][31:0] memory;

	// Runs each clock cycle
	always_ff @(posedge clk) begin
		// If the write is enabled, the data is moved
		// into the memory at the desired address
		if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end

	// Always sets the output of both read_data
	// vectors to be the data stored at the
	// corresponding read_addr location in memory
	always @(*) begin
		read_data1 = memory[read_addr1];
   end
  
   always @(*) begin
		read_data2 = memory[read_addr2];
	end

endmodule

