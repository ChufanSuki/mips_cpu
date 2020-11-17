module mips #(
parameter PHT_INDEX_BITS = 10 // assuming all PHTs(lcoal & global) are same size
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
   parameter LOCAL_PC_HASH_BITS = 3;
   
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
   wire             local_predict_takeF;
   wire             global_predict_takeF;
   wire [LOCAL_PC_HASH_BITS-1:0] pc_hashingF;
   wire [PHT_INDEX_BITS-1:0] local_PHT_indexF;
   wire [PHT_INDEX_BITS-1:0] global_PHT_indexF;
   wire [PHT_INDEX_BITS-1:0] local_PHT_indexE;
   wire [PHT_INDEX_BITS-1:0] global_PHT_indexE;
   wire [LOCAL_PC_HASH_BITS-1:0]   pc_hashingE;
   wire             local_predict_resultE;
   wire             global_predict_resultE;
   wire             actually_takenE;
   wire             branchE;
   wire             choice_predict;
   
   
   assign rsDt = rsD;
   assign rtDt = rtD;
   assign rsEt = rsE;
   assign rtEt = rtE;
   assign write_regEt = write_regE;
   assign write_regMt = write_regM;
   assign write_regWt = write_regW;
   assign instrDt = instrD; 
   assign predict_takeFt = predict_takeF;
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
    .local_predict_takeF(local_predict_takeF),
    .global_predict_takeF(global_predict_takeF),
    .pc_hashingF(pc_hashingF),
    .local_PHT_indexF(local_PHT_indexF),
    .global_PHT_indexF(global_PHT_indexF),
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
    .local_predict_resultE(local_predict_resultE),
    .global_predict_resultE(global_predict_resultE),
    .actually_takenE(actually_takenE),
    .branchE(branchE),
    .pc_hashingE(pc_hashingE),
    .local_PHT_indexE(local_PHT_indexE),
    .global_PHT_indexE(global_PHT_indexE),
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

   branch_predict_global branch_predictor_global(
   .clk(clk),
   .rst(rst),
   .pcF(pcF),
   .branchE(branchE),
   .PHT_indexE(global_PHT_indexE),
   .actually_takenE(actually_takenE),
   .predict_resultE(global_predict_resultE),
   .predict_takeF(global_predict_takeF),
   .PHT_indexF(global_PHT_indexF)
   );

   branch_predict_local branch_predictor_local(
                                         .clk(clk),
                                         .rst(rst),
                                         .pcF(pcF),
                                         .branchE(branchE),
                                         .BHT_indexE(pc_hashingE),
                                         .PHT_indexE(local_PHT_indexE),
                                         .actually_takenE(actually_takenE),
                                         .predict_resultE(local_predict_resultE),
                                         .predict_takeF(local_predict_takeF),
                                         .pc_hashingF(pc_hashingF),
                                         .PHT_indexF(local_PHT_indexF)
                                         );
   
   tournament_predictor tourname_predictor (
   .clk(clk),
   .rst(rst),
   .CPHT_indexE(global_PHT_indexE),
   .local_predict_resultE(local_predict_resultE),
   .global_predict_resultE(global_predict_resultE),
   .CPHT_indexF(global_PHT_indexF),
   .branchE(branchE),
   .choice_predict(choice_predict)
  );

   mux2 #(1) mux_predict(local_predict_takeF, global_predict_takeF, choice_predict, predict_takeF);
   
endmodule
