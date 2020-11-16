module mux2 
#(parameter p_nbits = 8) (
	input logic [p_nbits-1:0] d0,
  input logic [p_nbits-1:0] d1,
	input logic s,
	output wire [p_nbits-1:0] y
    );
	
	assign y = s ? d1 : d0;
   
endmodule
