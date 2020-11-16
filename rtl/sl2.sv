module sl2
#(parameter p_nbits=32) 
(
	input logic [p_nbits-1:0] x,
	output wire [p_nbits-1:0] y
	);

	assign y = {x[p_nbits-3:0],2'b00};
endmodule
