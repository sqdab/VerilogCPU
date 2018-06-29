module ALUcontrol (
	input  [10:0] Opcode,
	input  [1:0]  ALUop,
	output [3:0]  control);
	
	parameter	Rtype = 2'b10,
				Dtype = 2'b00,
				ADD   = 11'b10001011000,
				SUB   = 11'b11001011000,     
                AND   = 11'b10001010000,
				ORR = 	11'b10101010000,
				ADDI = 	11'b1001000100;
				
	reg [3:0] result;
	
	assign control = result;
				
				
	always @ (*) begin
		if (ALUop == Dtype)
			result = 4'b0010;
		else if (ALUop == Rtype)
			begin
			if (Opcode == ADD ||Opcode == ADDI)
				result = 4'b0010;
			else if (Opcode == SUB)
				result = 4'b0110;
			else if (Opcode == ORR)
				result = 4'b0001;
			else if (Opcode == AND)
				result = 4'b0000;
			end
		else
			result = 4'b0111;
	end
endmodule