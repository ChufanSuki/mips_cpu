`timescale 1ns / 1ps
module top(
	input logic         clk,
  input logic         reset,
	output logic [31:0] write_data,
  output logic [31:0] data_addr,
	output logic        mem_write
	);
	
  logic [31:0] pc;
	logic [31:0] read_data;
	logic [31:0] instr;
	
	mips mips(
		.clk(clk),
    .rst(reset),
		.read_data(read_data),
		.instr(instr),
		.write_data(write_data),
		.pc(pc),
		.mem_write(mem_write));
	
	imem inst_ram (
                 .a(pc[7:2]),
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
