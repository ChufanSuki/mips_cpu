`timescale 1ns / 1ps
module top(
	input logic         clk,
  input logic         reset,
	output wire [31:0] write_data,
  output wire [31:0] data_addr,
	output wire        mem_write,
	output wire [31:0] instr, // DEBUG
	output wire stallD, // DEBUG
	output wire branchD, // DEBUG
	output wire forward_AD,
  output wire forward_BD,
  output wire [1:0] forward_AE,
  output wire [1:0] forward_BE,
  output wire stallF,
  output wire flushE,
  output wire [4:0] rsE,
  output wire [4:0] rtE,
  output wire [4:0] rsD,
  output wire [4:0] rtD,
  output  wire [4:0]       write_regE,
  output wire [4:0]       write_regM,
  output wire [4:0]       write_regW,
  output wire [31:0]      instrD,
  output wire pc_srcD,
  output wire [31:0] pc_next,
  output wire predict_takeF,
  output wire predict_resultM,
  output wire actually_takenM,
  output wire [31:0] pc_plus4M
	);
	
  wire [31:0] pcF;
	wire [31:0] read_data;
	// wire [31:0] instr;
	
	mips mips(
		.clk(clk),
    .rst(reset),
		.read_data(read_data),
		.instr(instr),
		.write_data(write_data),
		.pcF(pcF),
		.mem_writeM(mem_write),
		.alu_outM(data_addr),
		.stallD(stallD),
		.branchD(branchD),
		.forward_AD(forward_AD),
    .forward_BD(forward_BD),
    .forward_AE(forward_AE),
    .forward_BE(forward_BE),
    .stallF(stallF),
    .flushE(flushE),
    .rsEt(rsE),
    .rsDt(rsD),
    .rtEt(rtE),
    .rtDt(rtD),
    .write_regEt(write_regE),
    .write_regMt(write_regM),
    .write_regWt(write_regW),
    .instrDt(instrD),
    .pc_srcDt(pc_srcD),
    .pc_nextt(pc_next),
    .predict_takeFt(predict_takeF),
    .predict_resultMt(predict_resultM),
    .actually_takenMt(actually_takenM),
    .pc_plus4Mt(pc_plus4M)
     );
	
	imem inst_ram (
                 .a(pcF[7:2]),
                 .rd(instr));
   
	/*
	data_ram data_RAM (
		.clka(~clk),
		.ena(1'b1),
		.wea(4{mem_write}),
		.addra(data_addr),
		.dina(write_data),
		.douta(read_data)
	);
   */
   dmem data_ram (
                  .clk(~clk),
                  .we(mem_write),
                  .a(data_addr),
                  .wd(write_data),
                  .rd(read_data));
   

endmodule
