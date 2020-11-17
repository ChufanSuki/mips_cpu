`timescale 1ns / 1ps

module testbench();
	reg clk;
	reg rst;

	wire[31:0] writedata,dataadr;
	wire memwrite;
	//-------DEBUG---------
	wire [31:0] instr;
	wire stallD;
	wire branchD;
	wire forward_AD;
    wire forward_BD;
  wire [1:0] forward_AE;
 wire [1:0] forward_BE;
   wire stallF;
   wire flushE;
     wire [4:0] rsE;
   wire [4:0] rtE;
   wire [4:0] rsD;
   wire [4:0] rtD;
     wire [4:0]       write_regE;
    wire [4:0]       write_regM;
    wire [4:0]       write_regW;
    wire [31:0] instrD;
    wire pc_srcD;
    wire [31:0] pc_next;
    wire predict_takeF;
    wire predict_resultE;
    wire actually_takenE;
    wire [31:0] pc_plus4E;
    //-------DEBUG END-----
	top dut(clk,rst,writedata,dataadr,memwrite, instr, stallD, branchD, forward_AD, forward_BD, forward_AE, forward_BE, stallF, flushE, 
	rsE, rtE, rsD, rtD, write_regE, write_regM, write_regW, instrD, pc_srcD, pc_next, predict_takeF, predict_resultE, actually_takenE, pc_plus4E);

	initial begin
		rst = 0;
		#40 rst = 1;
		#40 rst <= 0;
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
