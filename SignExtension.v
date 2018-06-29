module SignExtension(
input [31:0] instruction,
output [63:0] address);

parameter 	LDUR = 	11'b11111000010, 						    // Load
			STUR = 	11'b11111000000, 						    // Save
			ADD = 	11'b10001011000,							// Add
			ADDI = 	11'b1001000100,                             // Add immediate
			SUB = 	11'b11001011000,                            // Subtract
			AND = 	11'b10001010000,                            // Bit-wise And
			ORR = 	11'b10101010000,                            // Bit-wise Or
			CBZ = 	8'b10110100,        	                    // Compare and branch on zero
			CBNZ = 	8'b10110101,    	                        // Compare branch not-on-zero
			B = 	6'b000101,		                            // Unconditional Branch
			HALT = 	11'b11111111111,                            // End program 
			noop = 32'b00000_100000;
			
reg [63:0] result;

assign address = result;

always @ (*) begin
	if (instruction[31:26] == B)
		result = {{38{instruction[25]}}, instruction[25:0]};
	else if ((instruction[31:24] == CBNZ) || (instruction == CBZ))
		result = {{45{instruction[23]}}, instruction[23:5]};
	else if ((instruction[31:21] == LDUR) || (instruction[31:21] == STUR))
		result = {{55{instruction[20]}}, instruction[20:12]};
	else if (instruction[31:21] == ADDI)
		result = {{52{instruction[21]}}, instruction[21:10]};
	else
		result = 0;
end

endmodule