module pc
#(parameter p_nbits=32) (
	input logic clk,
  input logic rst,
	input logic [p_nbits-1:0] pc_next,
	output logic [p_nbits-1:0] pc
    );

	always @(posedge clk,posedge rst) begin
		if(rst) begin
			pc <= 0;
		end
		else begin
			pc <= pc_next;
		end
	end
endmodule
