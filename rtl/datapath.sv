`timescale 1ns / 1ps

module datapath(
	input logic         clk,
  input logic         rst,
	input logic [31:0]  instr,
  input logic [31:0]  read_dataM,
  input logic         reg_writeD,
  input logic         mem_to_regD,
  input logic         mem_writeD,
  input logic [2:0]   alu_controlD,
  input logic         alu_srcD,
  input logic         reg_dstD,
  input logic         branchD,
  input logic         jumpD,
  input logic         stallF,
  input logic         stallD,
  input logic         forward_AD,
  input logic         forward_BD,
  input logic         flushE,
  input logic [1:0]   forward_AE,
  input logic [1:0]   forward_BE,
  output logic [31:0] pcF,
  output logic [31:0] alu_outM,
  output logic [31:0] write_dataM,
  output logic        mem_writeM,
  output logic [4:0]  rsD,
  output logic [4:0]  rtD,
  output logic [4:0]  rsE,
  output logic [4:0]  rtE,
  output logic [4:0]  write_regE,
  output logic [4:0]  write_regM,
  output logic [4:0]  write_regW,
  output logic        mem_to_regE,
  output logic        mem_to_regM,
  output logic        reg_writeE,
  output logic        reg_writeM,
  output logic        reg_writeW
    );

   // Internal Signals
   logic [31:0] pc_next;
   logic [31:0] pc_temp;
   logic [31:0] pc_plus4F;
   logic [31:0] pc_plus4D;
   logic [31:0] pc_branchD;
   logic [31:0] pc_jumpD;
   logic        equalD;
   logic [31:0] sign_immD;
   logic [31:0] sign_immE;
   logic [31:0] sl2_immD;
   logic [31:0] rd1D;
   logic [31:0] rd2D;
   logic [31:0] rd1E;
   logic [31:0] rd2E;
   logic        pc_srcD;
   logic [4:0]  rdD;
   logic [4:0]  rdE;
   logic [31:0] instrD;
   logic        mem_writeE;
   logic [2:0]  alu_controlE;
   logic        alu_srcE;
   logic [31:0] alu_outE;
   logic        mem_to_regW;
   logic [31:0] alu_outW;
   logic [31:0] read_dataW;
   logic [31:0] write_dataE;
   logic        reg_dstE;
   logic [31:0] srcAE;
   logic [31:0] srcBE;
   logic [31:0] srcBE_temp;
   logic [31:0] resultW;
   logic [31:0] equal_src1;
   logic [31:0] equal_src2;
   
   //-------------IF----------------------------
   flopenr #(32) pc(
   .clk(clk),
   .reset(rst),
   .en(~stallF),
   .d(pc_next),
   .q(pcF));

   /* verilator lint_off PINMISSING */
   adder #(32) pc_plus4 (
   .in0(pcF),
   .in1(32'h4),
   .cin(1'b0),
   .out(pc_plus4F));
   /* verilator lint_onn PINMISSING */
   mux2 #(32) mux_pc1 (
   .d0(pc_plus4F),
   .d1(pc_branchD),
   .s(pc_srcD),
   .y(pc_temp)
   );

   mux2 #(32) mux_pc2 (
   .d0(pc_temp),
   .d1(pc_jumpD),
   .s(jumpD),
   .y(pc_next)
   );
   
   

   //-----------Registers-----------------------
   flopenrc #(32) pc_plus4_flop(
   .clk(clk),
   .rst(rst),
   .en(~stallD),
   .clear(pc_srcD),
   .d(pc_plus4F),
   .q(pc_plus4D));

   flopenrc #(32) instr_flop(
   .clk(clk),
   .rst(rst),
   .en(~stallD),
   .clear(pc_srcD),
   .d(instr),
   .q(instrD));
   
   //-------------------------------------------

   //-------------ID----------------------------
   assign rsD = instrD[25:21];
   assign rtD = instrD[20:16];
   assign rdD = instrD[15:11];
   regfile regfile(
   .clk(~clk),
   .reset(rst),
   .we3(reg_writeW),
   .ra1(rsD),
   .ra2(rtD),
   .wa3(write_regW),
   .wd3(resultW),
   .rd1(rd1D),
   .rd2(rd2D));

   mux2 #(32) mux_equalD1(
   .d0(rd1D),
   .d1(alu_outM),
   .s(forward_AD),
   .y(equal_src1)
   );
   
   mux2 #(32) mux_equalD2(
   .d0(rd2D),
   .d1(alu_outM),
   .s(forward_BD),
   .y(equal_src2)
   );

   assign equalD = (equal_src1 == equal_src2);
   assign pc_srcD = branchD & equalD;

   sign_extend sign_extend(
   .a(instr[15:0]),
   .y(sign_immD)
   );

   sl2 sl2_signimm(
   .x(sign_immD),
   .y(sl2_immD)
   );

   /* verilator lint_off PINMISSING */
   adder #(32) adder_branch(
   .cin(1'b0),
   .in0(pc_plus4D),
   .in1(sl2_immD),
   .out(pc_branchD)
   );
   /* verilator lint_on PINMISSING */
   
   assign pc_jumpD = {pc_plus4D[31:28], instrD[25:0], 2'b00};
   
   //-----------Register----------------------
   floprc #(1) flop_reg_writeD(clk, rst, flushE, reg_writeD, reg_writeE);
   floprc #(1) flop_mem_to_regD(clk, rst, flushE, mem_to_regD, mem_to_regE);
   floprc #(1) flop_mem_writeD(clk, rst, flushE, mem_writeD, mem_writeE);
   floprc #(3) flop_alu_controlD(clk, rst, flushE, alu_controlD, alu_controlE);
   floprc #(1) flop_alu_srcD(clk, rst, flushE, alu_srcD, alu_srcE);
   floprc #(1) flop_reg_dstD(clk, rst, flushE, reg_dstD, reg_dstE);
   floprc #(32) flop_rd1D(clk, rst, flushE, rd1D, rd1E);
   floprc #(32) flop_rd2D(clk, rst, flushE, rd2D, rd2E);
   floprc #(5) flop_rsD(clk, rst, flushE, rsD, rsE);
   floprc #(5) flop_rtD(clk, rst, flushE, rtD, rtE);
   floprc #(5) flop_rdD(clk, rst, flushE, rdD, rdE);
   floprc #(32) flop_sign_immD(clk, rst, flushE, sign_immD, sign_immE);
   
   //------------------------------------------

   //----------------EX------------------------
   mux3 #(32) mux_alu_srcA (rd1E, resultW, alu_outM, forward_AE, srcAE);
   mux3 #(32) mux_alu_srcB1 (rd2E, resultW, alu_outM, forward_BE, srcBE_temp);
   mux2 #(32) mux_alu_srcB2 (srcBE_temp, sign_immE, alu_srcE, srcBE);
   /* verilator lint_off PINMISSING */
   alu #(32) ALU(srcAE, srcBE, alu_controlE, alu_outE);
   /* verilator lint_on PINMISSING */
   assign write_dataE = srcBE_temp;
   mux2 #(5) mux_write_regE (rtE, rdE, reg_dstD, write_regE);
   //--------------Registers------------------
   flopr #(32) flop_aluE(clk, rst, alu_outE, alu_outM);
   flopr #(1) flop_reg_writeE(clk, rst, reg_writeE, reg_writeM);
   flopr #(1) flop_mem_to_regE(clk, rst, mem_to_regE, mem_to_regM);
   flopr #(1) flop_mem_writeE(clk, rst, mem_writeE, mem_writeM);
   flopr #(32) flop_write_dataE(clk, rst, write_dataE, write_dataM);
   flopr #(5) flop_write_regE(clk, rst, write_regE, write_regM);
   //------------------------------------------

   //-----------------MEM-----------------------
   
   //----------------Registers-----------------
   flopr #(1) flop_reg_writeM(clk, rst, reg_writeM, reg_writeW);
   flopr #(1) flop_mem_to_regM(clk, rst, mem_to_regM, mem_to_regW);
   flopr #(32) flop_alu_outM(clk, rst, alu_outM, alu_outW);
   flopr #(5) flop_write_regM(clk, rst, write_regM, write_regW);
   flopr #(32) flop_read_dataM(clk, rst, read_dataM, read_dataW);
   //------------------------------------------

   //----------------WB------------------------
   mux2 #(32) mux_resultW(alu_outW, read_dataW, mem_to_regW, resultW);
   //------------------------------------------
endmodule