typedef enum logic [$clog2(4)-1:0] {
   strongly_not_taken,
   weakly_not_taken,
   strongly_taken,
   weakly_taken
} predict_state_t;

module branch_predict_global #(
parameter PHT_INDEX_BITS = 10
)(
  input logic                      clk,
  input logic                      rst,
  input logic [31:0]               pcF,
  input logic                      branchE,
  input logic [PHT_INDEX_BITS-1:0] PHT_indexE,
  input logic                      actually_takenE,
  input logic                      predict_resultE,
  output wire                      predict_takeF,
  output wire [PHT_INDEX_BITS-1:0] PHT_indexF
  );

   parameter GHR_BITS = PHT_INDEX_BITS;
  // index of PHT = PC_HASHING XOR GHR
   parameter PC_HASH_BITS = GHR_BITS;
  // States
   parameter PHR_BITS = 2;

   reg [PHR_BITS-1:0] PHT[(1<<PHT_INDEX_BITS)-1:0];
   reg [GHR_BITS-1:0] GHR;
   reg [GHR_BITS-1:0] RGHR; // Retired GHR
   // Internal Signals
   integer            i;
   integer            j;
   wire [PC_HASH_BITS-1:0] pc_hashingF;
   // wire                predict_takeF;
   
   
   // Hashing
   assign pc_hashingF = pcF[PC_HASH_BITS-1:0]; // TODO: More Fancy Hashing Function 
   //------------Predict & Update When Fetch----------------
   assign PHT_indexF = pc_hashingF ^ GHR;
   assign predict_takeF = PHT[PHT_indexF][1];
   always @(posedge clk) begin
      if (rst) begin
         for (i= 0; i < GHR_BITS; i = i + 1) begin
            GHR[i] <= 0;
         end
      end
      else if (!predict_resultE) begin
         GHR <= RGHR;
      end
      else  begin
         GHR <= {GHR[GHR_BITS-2:0], predict_takeF};
      end
   end
   //-----------Execute when Decode----------------
   // TODO: Done In Datapath
   //-----------Examine when Execute---------------
   // TODO: Done In Datapath
   //-----------Remedy When MEMORY--------------------
   //-----------Training PHT-------------------------
   always @(posedge clk) begin
      if (rst) begin
         for (i = 0; i < (1<<PHT_INDEX_BITS); i = i + 1) begin
            PHT[i] = weakly_taken;
         end
      end
      else if (branchE) begin
         case (PHT[PHT_indexE])
           strongly_not_taken: begin
              if (predict_resultE)
                PHT[PHT_indexE] <= weakly_not_taken;
              else
                PHT[PHT_indexE] <= strongly_not_taken;
           end
           weakly_not_taken: begin
              if (predict_resultE)
                PHT[PHT_indexE] <= weakly_taken;
              else
                PHT[PHT_indexE] <= strongly_not_taken;
           end
           weakly_taken: begin
              if (predict_resultE)
                PHT[PHT_indexE] <= strongly_taken;
              else
                PHT[PHT_indexE] <= weakly_not_taken;
           end
           strongly_taken: begin
              if (predict_resultE)
                PHT[PHT_indexE] <= strongly_taken;
              else
                PHT[PHT_indexE] <= weakly_taken;
           end
         endcase // case (PHT[PHT_indexM])
      end
   end // always @ (posedge clk)
   
   //------------Update RGHR------------------
   always @(posedge clk) begin
      if (rst) begin
         for (j = 0; j < GHR_BITS; j = j + 1) begin
            RGHR[j] <= 0;
         end
      end
      else if (branchE) begin
         RGHR <= {RGHR[GHR_BITS-2:0], actually_takenE};
      end
   end
endmodule // branch_predict_global

