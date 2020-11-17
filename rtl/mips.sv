module mips #(
parameter PHT_INDEX_BITS = 10
)(
  input logic        clk,
  input logic        rst,
  input logic [31:0] read_data,
  input logic [31:0] instr,
  output wire [31:0] write_data,
  output wire [31:0] pcF,
  output wire        mem_writeM,
  output wire [31:0] alu_outM,
  // DEBUG
  output wire        stallD,
  output wire        branchD,
  output wire        forward_AD,
  output wire        forward_BD,
  output wire [1:0]  forward_AE,
  output wire [1:0]  forward_BE,
  output wire        stallF,
  output wire        flushE,
  output wire [4:0]  rsEt,
  output wire [4:0]  rtEt,
  output wire [4:0]  rsDt,
  output wire [4:0]  rtDt,
  output wire [4:0]  write_regEt,
  output wire [4:0]  write_regMt,
  output wire [4:0]  write_regWt,
  output wire [31:0] instrDt,
  output wire pc_srcDt,
  output wire [31:0] pc_nextt,
  output wire predict_takeFt,
  output wire predict_resultEt,
  output wire actually_takenEt,
  output wire [31:0] pc_plus4Et
  // DEBUG END
  
	);
   parameter PC_HASH_BITS = PHT_INDEX_BITS;
   
   //-----------internal signals--------
   wire [31:0]      instrD;
   wire             reg_writeD;
   wire             mem_to_regD;
   wire             mem_writeD;
   wire [2:0]       alu_controlD;
   wire             alu_srcD;
   wire             reg_dstD;
   // wire             branchD;
   wire             jumpD;
   // wire             stallF;
   // wire             stallD;
   // wire             forward_AD;
   // wire             forward_BD;
   // wire             flushE;
   // wire [1:0]       forward_AE;
   // wire [1:0]       forward_BE;
   wire [31:0]      write_dataM;
   wire [4:0]       rsD;
   wire [4:0]       rtD;
   wire [4:0]       rsE;
   wire [4:0]       rtE;
   wire [4:0]       write_regE;
   wire [4:0]       write_regM;
   wire [4:0]       write_regW;
   wire             mem_to_regE;
   wire             mem_to_regM;
   wire             reg_writeE;
   wire             reg_writeM;
   wire             reg_writeW;
   wire             predict_takeF;
   wire [PC_HASH_BITS-1:0] pc_hashingF;
   wire [PHT_INDEX_BITS-1:0] PHT_indexF;
   wire [PC_HASH_BITS-1:0]   pc_hashingE;
   wire [PHT_INDEX_BITS-1:0] PHT_indexE;
   wire             predict_resultE;
   wire             actually_takenE;
   wire             branchE;
   
   assign rsDt = rsD;
   assign rtDt = rtD;
   assign rsEt = rsE;
   assign rtEt = rtE;
   assign write_regEt = write_regE;
   assign write_regMt = write_regM;
   assign write_regWt = write_regW;
   assign instrDt = instrD; 
   assign predict_takeFt = predict_takeF;
   assign predict_resultEt = predict_resultE;
   assign actually_takenEt = actually_takenE;
   //-----------------------------------
   
	datapath mips_datapath(
    .clk(clk),
    .rst(rst),
    .reg_writeD(reg_writeD),
    .mem_to_regD(mem_to_regD),
    .mem_writeD(mem_writeD),
    .alu_controlD(alu_controlD),
    .alu_srcD(alu_srcD),
    .reg_dstD(reg_dstD),
    .branchD(branchD),
    .jumpD(jumpD),
    .stallF(stallF),
    .stallD(stallD),
    .forward_AD(forward_AD),
    .forward_BD(forward_BD),
    .flushE(flushE),
    .forward_AE(forward_AE),
    .forward_BE(forward_BE),
    .read_dataM(read_data),
    .instr(instr),
    .predict_takeF(predict_takeF),
    .PHT_indexF(PHT_indexF),
    //output
    .alu_outM(alu_outM),
    .write_dataM(write_data),
    .pcF(pcF),
    .mem_writeM(mem_writeM),
    .rsD(rsD),
    .rtD(rtD),
    .rsE(rsE),
    .rtE(rtE),
    .write_regE(write_regE),
    .write_regM(write_regM),
    .write_regW(write_regW),
    .mem_to_regE(mem_to_regE),
    .mem_to_regM(mem_to_regM),
    .reg_writeE(reg_writeE),
    .reg_writeM(reg_writeM),
    .reg_writeW(reg_writeW),
    .instrD(instrD),
    .predict_resultE(predict_resultE),
    .actually_takenE(actually_takenE),
    .branchE(branchE),
    .PHT_indexE(PHT_indexE),
    // DEBUG
    .pc_srcDt(pc_srcDt),
    .pc_nextt(pc_nextt),
    .pc_plus4Et(pc_plus4Et)
);

    controller Control(
		.op(instrD[31:26]),
		.funct(instrD[5:0]),
		.mem_to_reg(mem_to_regD),
    .mem_write(mem_writeD),
    .reg_dst(reg_dstD),
    .reg_write(reg_writeD),
    .jump(jumpD),
    .branch(branchD),
		.alu_control(alu_controlD),
    .alu_src(alu_srcD)
    );

    hazard Hazard(
        .rsD(rsD),
        .rtD(rtD),
        .rsE(rsE),
        .rtE(rtE),
        .write_regE(write_regE),
        .write_regM(write_regM),
        .write_regW(write_regW),
        .mem_to_regE(mem_to_regE),
        .mem_to_regM(mem_to_regM),
        .reg_writeE(reg_writeE),
        .reg_writeM(reg_writeM),
        .reg_writeW(reg_writeW),
        .branchD(branchD),
        .forward_AD(forward_AD),
        .forward_BD(forward_BD),
        .forward_AE(forward_AE),
        .forward_BE(forward_BE),
        .stallF(stallF),
        .stallD(stallD),
        .flushE(flushE));

   branch_predict_global branch_predictor(
   .clk(clk),
   .rst(rst),
   .pcF(pcF),
   .branchE(branchE),
   .PHT_indexE(PHT_indexE),
   .actually_takenE(actually_takenE),
   .predict_resultE(predict_resultE),
   .predict_takeF(predict_takeF),
   .PHT_indexF(PHT_indexF)
   );


endmodule
