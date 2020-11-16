module dmem(
 input logic         clk,
 input logic         we,
 input logic [31:0]  a,
 input logic [31:0]  wd,
 output logic [31:0] rd);
   
   logic [31:0]      RAM[63:0];
   assign rd = RAM[a[7:2]];
   always @(posedge clk)
     if (we) RAM[a[7:2]] <= wd;
   
endmodule // dmem
