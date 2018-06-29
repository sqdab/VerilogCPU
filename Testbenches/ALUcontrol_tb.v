`include "ALUcontrol.v"

module ALUcontrol_tb ();

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

reg [1:0] ALUop;
reg [10:0] Opcode;
wire [3:0] C;

initial begin
ALUop = 2'b10;
Opcode = SUB;

#5 Opcode = ADD;

#5 Opcode = ORR;

#5
begin
	Opcode = LDUR;
	ALUop = 2'b00;
end
end

ALUcontrol unit(Opcode, ALUop, C);

always @ (*) begin
$monitor("Opcode value: %62b", C);
end
endmodule