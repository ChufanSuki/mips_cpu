module isequal
#(parameter p_nbits=8) (
    input logic [p_nbits-1:0] x0,
    input logic [p_nbits-1:0] x1,
    output logic y
);
    assign y = (x0 == x1);
endmodule
