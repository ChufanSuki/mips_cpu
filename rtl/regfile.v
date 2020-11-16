`timescale 1ns / 1ps
module regfile(
	input logic         clk,
  input logic         reset,
	input logic         we3,
	input logic [4:0]   ra1,
  input logic [4:0]   ra2,
  input logic [4:0]   wa3,
	input logic [31:0]  wd3,
	output logic [31:0] rd1,
  output logic [31:0] rd2
    );

  // for pipelined processor, write third port on falling edge of clk
	 logic [31:0] rf[31:0];
   integer   i;
   
	always @(posedge reset) begin
     if (reset) begin
        for (i = 0; i < 32; i = i + 1)
          rf[i] = 0;
	   end
  end

   always @(posedge clk) begin
      if (we3)
        rf[wa3] <= wd3;
   end
	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule
