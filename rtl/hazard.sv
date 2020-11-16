`timescale 1ns/1ps

module hazard(
    input logic [4:0] rsD,
    input logic [4:0] rtD,
    input logic [4:0] rsE,
    input logic [4:0] rtE,
    input logic [4:0] write_regE,
    input logic [4:0] write_regM,
    input logic [4:0] write_regW,
    input logic       mem_to_regE,
    input logic       mem_to_regM,
    input logic       reg_writeE,
    input logic       reg_writeM,
    input logic       reg_writeW,
    input logic       branchD,
    output wire      forward_AD,
    output wire      forward_BD,
    output logic [1:0] forward_AE,
    output logic [1:0] forward_BE,
    output wire      stallF,
    output wire      stallD,
//    output wire      flushD,
    output wire      flushE
//    output wire      flushM
);
   wire              lw_stall;
   wire              branch_stall;
   
//---------Solve Data Hazard with Forwarding-----------

   always @(*) begin
      if ((rsE != 0) && (rsE == write_regM) && reg_writeM)
        forward_AE = 2'b10;
      else if ((rsE != 0) && (rsE == write_regW) && reg_writeW)
        forward_AE = 2'b01;
      else
        forward_AE = 2'b00;
   end

   always @(*) begin
      if ((rtE != 0) && (rtE == write_regM) && reg_writeM)
        forward_BE = 2'b10;
      else if ((rtE != 0) && (rtE == write_regW) && reg_writeW)
        forward_BE = 2'b01;
      else
        forward_BE = 2'b00;
   end
//-------------------------------------------------------

//--------Solve Data hazard with stall-------------------
   assign lw_stall = ((rsD == rtE) || (rtD == rtE)) && mem_to_regE;

//-------------------------------------------------------
   
//-------Solve Control Hazard with Early Decision and Forwarding---
   assign forward_AD = (rsD != 0) && (rsD == write_regM) && reg_writeM;
   assign forward_BD = (rtD != 0) && (rtD == write_regM) && reg_writeM;
   assign branch_stall = branchD && reg_writeE && (write_regE == rsD || write_regE == rtD)
     || branchD && mem_to_regM && (write_regM == rsD || write_regM == rtD);
//--------------------------------------------------------------    
   assign stallF = lw_stall || branch_stall;
   assign stallD = lw_stall || branch_stall;
   assign flushE = lw_stall || branch_stall;
endmodule // hazard

