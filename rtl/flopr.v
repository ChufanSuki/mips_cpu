module flopr 
#(parameter p_nbits=8)(
    input  logic clk,
    input  logic rst,
    input  logic [p_nbits-1:0] d,
    output logic   [p_nbits-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            q <= 0;
        end
        else begin
            q <= d;
        end
    end
   
endmodule // flopr

