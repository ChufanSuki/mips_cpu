module flopenr
#(parameter p_nbits=8)(
    input  logic clk,
    input  logic en,
    input  logic reset,
    input  logic [p_nbits-1:0] d,
    output logic [p_nbits-1:0] q
);
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            q <= 0;
        end
        else if(en) begin
            q <= d;
        end
    end // always @ (posedge clk, posedge rst)
   
endmodule // flopenr
