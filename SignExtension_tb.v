`include "SignExtension.v"

module SignExtension_tb ();

wire [63:0] SignExtendOut;

SignExtension SE (32'b11111000010000010000000000000111, SignExtendOut);

always @ (*) begin
	$monitor(SignExtendOut);
end

endmodule