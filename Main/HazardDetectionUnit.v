module HazardDetectionUnit(
	input IDEXMemRead,
	input [4:0] IDEXRd,
	input [4:0] IFIDRn,
	input [4:0] IFIDRm,
	output Stall);
	
assign Stall = !IDEXMemRead ? 0 : ((IDEXRd == IFIDRn) || (IDEXRd == IFIDRm)) ? 1 : 0;
	
endmodule