module alu 
#(parameter p_nbits = 32)(
    input logic  [p_nbits-1:0]  a,
    input logic  [p_nbits-1:0]  b,
    input logic  [2:0]        op,
    output logic [p_nbits-1:0]  res,
    output logic              zero
);
   
   assign res = (op == 3'b000) ? a & b:
                (op == 3'b001) ? a | b:
                (op == 3'b010) ? a + b:
                (op == 3'b110) ? a - b:
                (op == 3'b111) ? (a<b) ? 32'h1 : 32'h0 :
                32'b0;

   assign zero = ((a-b) == 0);
   
endmodule // alu
