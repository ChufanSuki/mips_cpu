`timescale 1ns / 1ps

module alu_decoder(
	input  logic [5:0] funct,
	input  logic [1:0] alu_op,
	output logic [2:0] alu_control
  );

// 	Opcode	AluOp	Funct	 ALU control
// 	lw		  00		XXXXXX 		010
// 	sw		  00		XXXXXX  	010
// 	addi	  00		XXXXXX	  010
// 	Beq		  01		XXXXXX		110
// 	R-type	1x		100000		010
// 					1x    100010		110
// 					1x    100100  	000
// 					1x    100101		001
// 					1x    101010	  111

	always @(*) begin
     
		casez(alu_op)
			2'b00: alu_control = 3'b010;
			2'b01: alu_control = 3'b110;
			2'b1?: begin
         
				case(funct)
					6'b100000: alu_control = 3'b010;
					6'b100010: alu_control = 3'b110;
					6'b100100: alu_control = 3'b000;
					6'b100101: alu_control = 3'b001;
					6'b101010: alu_control = 3'b111;
					default:   alu_control = 3'b000;
				endcase // case (funct)
         
			end
		endcase // casez (alu_op)
     
	end // always @ (*)
   
endmodule
