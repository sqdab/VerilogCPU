`include "ALU.v"

module ALU_tb ();

parameter	AND = 4'b0000,
			OR = 4'b0001,
			ADD = 4'b0010,
			SUB = 4'b0110,
			NONE = 4'b0111;

reg [61:0] A, B;
wire [61:0] C;
reg [3:0] control;

initial begin
A = 2; // Change input values to change test
B = 1;
control = AND;
#5 control = OR;
#5 control = ADD;
#5 control = SUB;
#5 control = NONE;
end

ALU alu(A, B, control, C);

always @ (control) begin
$monitor("ALU output value: %2d", C);
end
endmodule