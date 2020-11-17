`timescale 1ns / 1ps
module datapath #(
parameter PHT_INDEX_BITS = 10
)(
  input logic                      clk,
  input logic                      rst,
  input logic [31:0]               instr,
  input logic [31:0]               read_dataM,
  input logic                      reg_writeD,
  input logic                      mem_to_regD,
  input logic                      mem_writeD,
  input logic [2:0]                alu_controlD,
  input logic                      alu_srcD,
  input logic                      reg_dstD,
  input logic                      branchD,
  input logic                      jumpD,
  input logic                      stallF,
  input logic                      stallD,
  input logic                      forward_AD,
  input logic                      forward_BD,
  input logic                      flushE,
  input logic [1:0]                forward_AE,
  input logic [1:0]                forward_BE,
  input logic                      predict_takeF,
  input logic [PHT_INDEX_BITS-1:0] PHT_indexF,
  output wire [31:0]               pcF,
  output wire [31:0]               alu_outM,
  output wire [31:0]               write_dataM,
  output wire                      mem_writeM,
  output wire [4:0]                rsD,
  output wire [4:0]                rtD,
  output wire [4:0]                rsE,
  output wire [4:0]                rtE,
  output wire [4:0]                write_regE,
  output wire [4:0]                write_regM,
  output wire [4:0]                write_regW,
  output wire                      mem_to_regE,
  output wire                      mem_to_regM,
  output wire                      reg_writeE,
  output wire                      reg_writeM,
  output wire                      reg_writeW,
  output wire [31:0]               instrD,
  output wire                      predict_resultE,
  output wire                      actually_takenE,
  output wire                      branchE,
  output wire [PHT_INDEX_BITS-1:0] PHT_indexE,
  // DEBUG
  output wire                      pc_srcDt,
  output wire [31:0]               pc_nextt,
  output wire [31:0]               pc_plus4Et
    );

   parameter PC_HASH_BITS = PHT_INDEX_BITS;
   
   // Internal Signals
   wire [31:0] pc_next;
  // wire [31:0] pcF_temp;
   wire [31:0] pc_temp;
   wire [31:0] pc_plus4F;
   wire [31:0] pc_plus4D;
   wire [31:0] pc_branchD;
   wire [31:0] pc_branchE;
   wire [31:0] pc_branchM;
   wire [31:0] pc_jumpD;
   wire [31:0] pc_next_temp;
   wire [PC_HASH_BITS-1:0] pc_hashingD;
//   wire [PC_HASH_BITS-1:0] pc_hashingE;
   wire [PHT_INDEX_BITS-1:0] PHT_indexD;
//   wire [PHT_INDEX_BITS-1:0] PHT_indexE;
//   wire                       branchE;
//   wire                       actually_takenE;
//   wire                       predict_resultE;
   // wire        equalD;
   wire [31:0] sign_immD;
   wire [31:0] sign_immE;
   wire [31:0] sl2_immD;
   wire [31:0] rd1D;
   wire [31:0] rd2D;
   wire [31:0] rd1E;
   wire [31:0] rd2E;
   wire        pc_srcD;
   wire [4:0]  rdD;
   wire [4:0]  rdE;
   wire        mem_writeE;
   wire [2:0]  alu_controlE;
   wire        alu_srcE;
   wire [31:0] alu_outE;
   wire        mem_to_regW;
   wire [31:0] alu_outW;
   wire [31:0] read_dataW;
   wire [31:0] write_dataE;
   wire        reg_dstE;
   wire [31:0] srcAE;
   wire [31:0] srcBE;
   wire [31:0] srcBE_temp;
   wire [31:0] resultW;
   wire [31:0] equal_src1D;
   wire [31:0] equal_src2D;
   wire [31:0] equal_src1E;
   wire [31:0] equal_src2E;
   wire        zero;
   wire        predict_takeD;
   wire        predict_takeE;
   wire        clear_id_ex;
   wire [31:0] pc_plus4E;
   //wire [PHT_INDEX_BITS-1:0] PHT_indexD;
   
//   wire [31:0] pc_plus4M;
   
   
assign pc_srcDt = pc_srcD;
assign pc_nextt = pc_next;
   assign pc_plus4Et = pc_plus4E;
   //-------------IF----------------------------
   flopenr #(32) pc(
   .clk(clk),
   .reset(rst),
   .en(~stallF),
   .d(pc_next),
   .q(pcF));

   //assign pcF = predict_resultM ? pcF_temp : (actually_takenM ? pc_branchM : pc_plus4M);
   
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
   .y(pc_next_temp)
   );

   assign pc_next = predict_resultE ? pc_next_temp : (actually_takenE ? pc_branchE : pc_plus4E);
   

   //-----------Registers-----------------------
   flopenrc #(32) pc_plus4_flop(
   .clk(clk),
   .rst(rst),
   .en(~stallD),
   .clear(pc_srcD || jumpD || ~predict_resultE),
   .d(pc_plus4F),
   .q(pc_plus4D));

   flopenrc #(32) instr_flop(
   .clk(clk),
   .rst(rst),
   .en(~stallD),
   .clear(pc_srcD || jumpD || ~predict_resultE),
   .d(instr),
   .q(instrD));

   flopenrc #(1) prdictor_flopD(
   .clk(clk),
   .rst(rst),
   .en(~stallD),
   .clear(pc_srcD || jumpD || ~predict_resultE),
   .d(predict_takeF),
   .q(predict_takeD));

   flopenrc #(PHT_INDEX_BITS) PHT_index_flopD(clk, rst, ~stallD, pc_srcD||jumpD||~predict_resultE, PHT_indexF, PHT_indexD);

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
   .y(equal_src1D)
   );
   
   mux2 #(32) mux_equalD2(
   .d0(rd2D),
   .d1(alu_outM),
   .s(forward_BD),
   .y(equal_src2D)
   );

   // assign equalD = (equal_src1 == equal_src2);
   assign pc_srcD = branchD & predict_takeD;

   sign_extend sign_extend(
   .a(instrD[15:0]),
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
   assign clear_id_ex = flushE || ~predict_resultE;
   floprc #(1) flop_reg_writeD(clk, rst, clear_id_ex, reg_writeD, reg_writeE);
   floprc #(1) flop_mem_to_regD(clk, rst, clear_id_ex, mem_to_regD, mem_to_regE);
   floprc #(1) flop_mem_writeD(clk, rst, clear_id_ex, mem_writeD, mem_writeE);
   floprc #(3) flop_alu_controlD(clk, rst, clear_id_ex, alu_controlD, alu_controlE);
   floprc #(1) flop_alu_srcD(clk, rst, clear_id_ex, alu_srcD, alu_srcE);
   floprc #(1) flop_reg_dstD(clk, rst, clear_id_ex, reg_dstD, reg_dstE);
   floprc #(32) flop_rd1D(clk, rst, clear_id_ex, rd1D, rd1E);
   floprc #(32) flop_rd2D(clk, rst, clear_id_ex, rd2D, rd2E);
   floprc #(5) flop_rsD(clk, rst, clear_id_ex, rsD, rsE);
   floprc #(5) flop_rtD(clk, rst, clear_id_ex, rtD, rtE);
   floprc #(5) flop_rdD(clk, rst, clear_id_ex, rdD, rdE);
   floprc #(32) flop_sign_immD(clk, rst, clear_id_ex, sign_immD, sign_immE);
   floprc #(32) flop_equal_src1D(clk, rst, clear_id_ex, equal_src1D, equal_src1E);
   floprc #(32) flop_equal_src2D(clk, rst, clear_id_ex, equal_src2D, equal_src2E);
   floprc #(1) flop_branchD(clk, rst, clear_id_ex, branchD, branchE);
   floprc #(32) flop_pc_branchD(clk, rst, clear_id_ex, pc_branchD, pc_branchE);
   floprc #(32) flop_pc_plus4D(clk, rst, clear_id_ex, pc_plus4D, pc_plus4E);
   floprc #(1) flop_predict_takeD(clk, rst, clear_id_ex, predict_takeD, predict_takeE);
   floprc #(PHT_INDEX_BITS) flop_PHT_indexD(clk, rst, clear_id_ex, PHT_indexD, PHT_indexE);
   

   //------------------------------------------

   //----------------EX------------------------
   mux3 #(32) mux_alu_srcA (rd1E, resultW, alu_outM, forward_AE, srcAE);
   mux3 #(32) mux_alu_srcB1 (rd2E, resultW, alu_outM, forward_BE, srcBE_temp);
   mux2 #(32) mux_alu_srcB2 (srcBE_temp, sign_immE, alu_srcE, srcBE);
   /* verilator lint_off PINMISSING */
   alu #(32) ALU(srcAE, srcBE, alu_controlE, alu_outE, zero);
   /* verilator lint_on PINMISSING */
   assign write_dataE = srcBE_temp;
   mux2 #(5) mux_write_regE (rtE, rdE, reg_dstE, write_regE);
   assign actually_takenE = (equal_src1E == equal_src2E);
   // branchE predict_takeE equalE  result
   //   0         x           x       1
   //   1         1           1       1
   //   1         0           0       1
   assign predict_resultE = (branchE && (predict_takeE == actually_takenE)) || (~branchE);
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
