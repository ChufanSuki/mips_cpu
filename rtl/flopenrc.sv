module flopenrc
#(parameter p_nbits=8)
(
  input logic  clk,
  input logic  en,
  input logic  rst,
  input logic  clear,
  input logic [p_nbits-1:0]   d,
  output logic [p_nbits-1:0]  q
);
   always @(posedge clk, posedge rst) begin
      if(rst) begin
         q <= 0;
      end
      else if(clear) begin
         q <= 0;
      end
      else if(en) begin
         q <= d;
      end
      else begin
         q <= q;
      end
   end
endmodule
