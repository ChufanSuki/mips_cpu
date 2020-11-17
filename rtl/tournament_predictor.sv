typedef enum logic [$clog2(4)-1:0] {
   strongly_take_global,
   weakly_take_global,
   weakly_take_local,
   strongly_take_local
} predict_choice_state_t;

module tournament_predictor #(
parameter CPHT_INDEX_BITS = 10
)(
  input logic                       clk,
  input logic                       rst,
  input logic [CPHT_INDEX_BITS-1:0] CPHT_indexE,
  input logic                       local_predict_resultE,
  input logic                       global_predict_resultE,
  input logic [CPHT_INDEX_BITS-1:0] CPHT_indexF,
  input logic                       branchE,
  output wire                       choice_predict // 0 global, 1 local
  );

  // States
   parameter CPHR_BITS = 2;
   reg [CPHR_BITS-1:0] CPHT[(1<<CPHT_INDEX_BITS)-1:0];
   // Internal Signals
   integer            i;
   integer            j;
   // Hashing
   //------------Predict & Update When Fetch----------------
   assign choice_predict = CPHT[CPHT_indexF][1];
   //-----------Execute when Decode----------------
   // TODO: Done In Datapath
   //-----------Examine when Execute---------------
   // TODO: Done In Datapath
   //-----------Remedy When MEMORY--------------------
   //-----------Training PHT-------------------------
   always @(posedge clk) begin
      if (rst) begin
         for (i = 0; i < (1<<CPHT_INDEX_BITS); i = i + 1) begin
            CPHT[i] = weakly_take_local;
         end
      end
      else if (branchE) begin
         case (CPHT[CPHT_indexE])
           strongly_take_global: begin
              if (!global_predict_resultE && local_predict_resultE)
                CPHT[CPHT_indexE] <= weakly_take_global;
              else
                CPHT[CPHT_indexE] <= strongly_take_global;
           end
           weakly_take_global: begin
              if (global_predict_resultE && !local_predict_resultE)
                CPHT[CPHT_indexE] <= strongly_take_global;
              else if (!global_predict_resultE && local_predict_resultE)
                CPHT[CPHT_indexE] <= weakly_take_local;
              else
                CPHT[CPHT_indexE] <= weakly_take_global;
           end
           weakly_take_local: begin
              if (!global_predict_resultE && local_predict_resultE)
                CPHT[CPHT_indexE] <= strongly_take_local;
              else if (global_predict_resultE && !local_predict_resultE)
                CPHT[CPHT_indexE] <= weakly_take_global;
              else
                CPHT[CPHT_indexE] <= weakly_take_local;
           end
           strongly_take_local: begin
              if (global_predict_resultE && !local_predict_resultE)
                CPHT[CPHT_indexE] <= weakly_take_local;
              else
                CPHT[CPHT_indexE] <= strongly_take_local;
           end
         endcase // case (CPHT[CPHT_indexM])
      end
   end // always @ (posedge clk)
endmodule // tournament_predictor
