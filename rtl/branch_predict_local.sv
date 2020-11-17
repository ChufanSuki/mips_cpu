typedef enum logic [$clog2(4)-1:0] {
   strongly_not_taken,
   weakly_not_taken,
   strongly_taken,
   weakly_taken
} predict_state_t;

module branch_predict_local #(
parameter PHT_INDEX_BITS = 7,
parameter BHT_INDEX_BITS = 3,
parameter BHR_BITS = 4,
parameter PC_TAIL = 2
)(
  input logic                      clk,
  input logic                      rst,
  input logic [31:0]               pcF,
  input logic                      branchM,
  input logic [BHT_INDEX_BITS-1:0] BHT_indexM,
  input logic [PHT_INDEX_BITS-1:0] PHT_indexM,
  input logic                      actually_takenM,
  input logic                      predict_resultM,
  output wire                      predict_takeF,
  output wire [BHT_INDEX_BITS-1:0] pc_hashingF,
  output wire [PHT_INDEX_BITS-1:0] PHT_indexF
  );
   
  // BHR = {PC[PC_HEAD:PC_TAIL], BHT[PC_HASH]}
   parameter PC_SEGMENT_LENGTH = PHT_INDEX_BITS - BHR_BITS;
   parameter PC_HEAD = PC_TAIL + PC_SEGMENT_LENGTH - 1;
   parameter PC_HASH_BITS = BHT_INDEX_BITS;
  // States
   parameter PHR_BITS = 2;
  // parameter strongly_not_taken = 2'b00;
  // parameter weakly_not_taken = 2'b01;
  // parameter weakly_taken = 2'b11;
  // parameter strongly_taken = 2'b10;
   

   reg [BHR_BITS-1:0] BHT [(1<<BHT_INDEX_BITS)-1:0];
   reg [PHR_BITS-1:0] PHT[(1<<PHT_INDEX_BITS)-1:0];

   // Internal Signals
   integer            i;
   integer            j;
   wire [BHR_BITS-1:0] BHRF;
   
   // Hashing
   assign pc_hashingF = pcF[PC_HASH_BITS-1:0]; // TODO: More Fancy Hashing Function 
   //------------Predict When Fetch----------------
   assign BHRF = BHT[pc_hashingF];
   assign PHT_indexF = {pcF[PC_HEAD:PC_TAIL], BHRF};
   assign predict_takeF = PHT[PHT_indexF][1];
   //-----------Execute when Decode----------------
   // TODO: Done In Datapath
   //-----------Examine when Execute---------------
   // TODO: Done In Datapath
   //-----------Update When MEMORY--------------------
   //-----------Training PHT-------------------------
   always @(posedge clk) begin
      if (rst) begin
         for (i = 0; i < (1<<PHT_INDEX_BITS); i = i + 1) begin
            PHT[i] = weakly_taken;
         end
      end
      else if (branchM) begin
         case (PHT[PHT_indexM])
           strongly_not_taken: begin
              if (predict_resultM)
                PHT[PHT_indexM] <= weakly_not_taken;
              else
                PHT[PHT_indexM] <= strongly_not_taken;
           end
           weakly_not_taken: begin
              if (predict_resultM)
                PHT[PHT_indexM] <= weakly_taken;
              else
                PHT[PHT_indexM] <= strongly_not_taken;
           end
           weakly_taken: begin
              if (predict_resultM)
                PHT[PHT_indexM] <= strongly_taken;
              else
                PHT[PHT_indexM] <= weakly_not_taken;
           end
           strongly_taken: begin
              if (predict_resultM)
                PHT[PHT_indexM] <= strongly_taken;
              else
                PHT[PHT_indexM] <= weakly_taken;
           end
         endcase // case (PHT[PHT_indexM])
      end
   end // always @ (posedge clk)
   
   //------------Update BHT------------------
   always @(posedge clk) begin
      if (rst) begin
         for (j = 0; j < (1<<BHT_INDEX_BITS); j = j + 1) begin
            BHT[j] <= 0;
         end
      end
      else if (branchM) begin
         BHT[BHT_indexM] <= {BHT[BHT_indexM][BHR_BITS-2:0], actually_takenM};
      end
   end
endmodule // branch_predict_local

