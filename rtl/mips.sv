module mips(
	input logic clk,
  input logic rst,
	input logic [31:0] read_data,
	input logic [31:0] instr,
  output wire [31:0] write_data,
  output wire [31:0] pc,
  output wire        mem_write
	);

   //-----------internal signals--------
   wire             reg_writeD;
   wire             mem_to_regD;
   wire             mem_writeD;
   wire [2:0]       alu_controlD;
   wire             alu_srcD;
   wire             reg_dstD;
   wire             branchD;
   wire             jumpD;
   wire             stallF;
   wire             stallD;
   wire             forward_AD;
   wire             forward_BD;
   wire             flushE;
   wire [1:0]       forward_AE;
   wire [1:0]       forward_BE;
   wire [31:0]      pcF;
   wire [31:0]      alu_outM;
   wire [31:0]      write_dataM;
   wire             mem_writeM;
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
   
                     
   
   
   //-----------------------------------
   assign read_dataM = read_data;
   
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
    //output
    .alu_outM(alu_outM),
    .write_dataM(write_data),
    .pcF(pc),
    .mem_writeM(mem_write),
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
    .reg_writeW(reg_writeW));

    controller Control(
		.op(instr[31:26]),
		.funct(instr[5:0]),
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

endmodule
