`timescale 1ns / 1ps

module main_decoder(
                    input  logic [5:0] op,
                    output logic reg_dst,
                    output logic reg_write,
                    output logic alu_src,
                    output logic mem_write,
                    output logic mem_to_reg,
                    output logic branch,
                    output logic jump,
                    output logic [1:0] alu_op);
    
    always @(*) begin
        case (op)
            //R-type
            6'b000000: begin
                jump     = 1'b0;
                reg_write= 1'b1;
                reg_dst   = 1'b1;
                alu_src   = 1'b0;
                branch   = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 2'b10;
            end
            //lw
            6'b100011: begin
                jump     = 1'b0;
                reg_write = 1'b1;
                reg_dst   = 1'b0;
                alu_src   = 1'b1;
                branch   = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b1;
                alu_op    = 2'b00;
            end
            //sw
            6'b101011: begin
                jump     = 1'b0;
                reg_write = 1'b0;
                reg_dst   = 1'b0;
                alu_src   = 1'b1;
                branch   = 1'b0;
                mem_write = 1'b1;
                mem_to_reg = 1'b0;
                alu_op    = 2'b00;
            end
            //beq
            6'b000100: begin
                jump     = 1'b0;
                reg_write = 1'b0;
                reg_dst   = 1'b0;
                alu_src   = 1'b0;
                branch   = 1'b1;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 2'b01;
            end
            //addi
            6'b001000: begin
                jump     = 1'b0;
                reg_write = 1'b1;
                reg_dst   = 1'b0;
                alu_src   = 1'b1;
                branch   = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 2'b00;
            end
            //j
            6'b000010: begin
                jump     = 1'b1;
                reg_write = 1'b0;
                reg_dst   = 1'b0;
                alu_src   = 1'b0;
                branch   = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 2'b00;
            end
            default: begin
                jump     = 1'b0;
                reg_write = 1'b0;
                reg_dst   = 1'b0;
                alu_src   = 1'b0;
                branch   = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op    = 2'b00;
            end
        endcase
    end
    
endmodule
