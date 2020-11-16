module mux3
#(parameter p_nbits=8) (
    input logic [p_nbits-1:0] x0,
    input logic [p_nbits-1:0] x1,
    input logic [p_nbits-1:0] x2,
    input logic [1:0] s,
    output logic [p_nbits-1:0] y
);
    always @(*) begin
        case(s)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x0;
        endcase
    end
endmodule
