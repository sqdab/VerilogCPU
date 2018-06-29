module ForwardingUnit(
	input EXMEMRegWrite,
	input MEMWBRegWrite,
	input [4:0] Rn,
	input [4:0] Rm,
	input [4:0] EXMEMRd,
	input [4:0] MEMWBRd,
	output [1:0] ForwardA,
	output [1:0] ForwardB);
	
assign ForwardA = EXMEMRegWrite && (EXMEMRd != 31) && (EXMEMRd == Rn) ? 2'b10 :
				MEMWBRegWrite && (MEMWBRd != 31) && (EXMEMRd == Rn) ? 2'b01 :
				2'b00;
assign ForwardB = EXMEMRegWrite && (EXMEMRd != 31) && (EXMEMRd == Rm) ? 2'b10 :
				MEMWBRegWrite && (MEMWBRd != 31) && (MEMWBRd == Rm) ? 2'b01 :
				2'b00;

endmodule