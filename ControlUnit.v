module ControlUnit (	
	input [10:0] instruction,
	output Reg2Loc,
	output BranchZ,
	output BranchNZ,
	output MemRead,
	output Mem2Reg,
	output [1:0] ALUop,
	output MemWrite,
	output ALUsrc,
	output RegWrite,
	output UncondBranch,
	output stopExecution);

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
			

assign Reg2Loc = (instruction == STUR) || (instruction[10:3] == CBNZ) || (instruction[10:3] == CBZ);
assign BranchZ = (instruction[10:3] == CBZ);
assign BranchNZ = (instruction[10:3] == CBNZ);
assign ALUsrc = (instruction == STUR) || (instruction == LDUR) || (instruction == ADDI);
assign Mem2Reg = instruction == LDUR;
assign RegWrite = (instruction == ADD) || (instruction == ADDI) || (instruction == SUB) || (instruction == AND) || (instruction == ORR) || (instruction == LDUR);
assign MemRead = instruction == LDUR;
assign MemWrite = instruction == STUR;
assign ALUop[1] = (instruction == ADD) || (instruction == ADDI) || (instruction == SUB) || (instruction == AND) || (instruction == ORR);
assign ALUop[0] = (instruction[10:3] == CBZ) || (instruction[10:3] == CBNZ);
assign UncondBranch = instruction[10:5] == B;
assign stopExecution = instruction == HALT;


endmodule