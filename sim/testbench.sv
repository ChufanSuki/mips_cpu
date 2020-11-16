`timescale 1ns / 1ps

module testbench();
	reg clk;
	reg rst;

	wire[31:0] writedata,dataadr;
	wire memwrite;
	top dut(clk,rst,writedata,dataadr,memwrite);

	initial begin
		rst = 0;
		#20 rst = 1;
		#20 rst <= 0;
	end

	always begin
		clk <= 1;
		#20;
		clk <= 0;
		#20;
	 
	end

	always @(negedge clk) begin
		if(memwrite) begin
			/* code */
			if(dataadr === 84 & writedata === 7) begin
				/* code */
				$display("Simulation succeeded");
				$stop;
			end else if(dataadr !== 80) begin
				/* code */
				$display("Simulation Failed");
				//$stop;
			end
		end
	end
endmodule
