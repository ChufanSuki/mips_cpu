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
      else if(clear && en) begin // Take care of branch predict taken and stall happen at the same time 
         q <= 0;
      end
      else if(en) begin
         q <= d;
      end
   end
endmodule
