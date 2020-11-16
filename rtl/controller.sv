`timescale 1ns / 1ps
module controller(
	input logic [5:0]  op,
	input logic [5:0]  funct,
  output wire       mem_to_reg,
  output wire       mem_write,
  output wire       alu_src,
  output wire       reg_dst,
  output wire       reg_write,
  output wire       jump,
  output wire       branch,
  output wire [2:0] alu_control
);
	
	 wire [1:0] alu_op;
   
	main_decoder main_decoder(
		.op(op),
		.mem_to_reg(mem_to_reg),
    .mem_write(mem_write),
    .branch(branch),
    .alu_src(alu_src),
    .reg_dst(reg_dst),
    .reg_write(reg_write),
    .jump(jump),
		.alu_op(alu_op)
	);

	alu_decoder alu_decoder(
		.funct(funct),
		.alu_op(alu_op),
		.alu_control(alu_control)
	);
   
endmodule // controller

