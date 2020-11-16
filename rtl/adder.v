module full_adder(
	input  cin,
  input  x,
  input  y,
	output s,
  output cout
	);

	assign s  = x ^ y ^ cin;
	assign cout = (x & y) | (x & cin) | (y & cin);
endmodule

module adder
#(
  parameter p_nbits = 32
)(
	output [p_nbits-1:0] out,
	output               cout,
  input                cin,
	input [p_nbits-1:0]  in0,
  input [p_nbits-1:0]  in1
	);
   /* verilator lint_off WIDTH */
   assign {cout, out} = in0 + in1 + cin;
   /* verilator lint_on WIDTH */

endmodule
