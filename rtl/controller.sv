`timescale 1ns / 1ps
module controller(
	input logic [5:0]  op,
	input logic [5:0]  funct,
  output logic       mem_to_reg,
  output logic       mem_write,
  output logic       alu_src,
  output logic       reg_dst,
  output logic       reg_write,
  output logic       jump,
  output logic       branch,
  output logic [2:0] alu_control
);
	
	 logic [1:0] alu_op;
   
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

