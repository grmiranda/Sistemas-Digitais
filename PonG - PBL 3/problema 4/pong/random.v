module random (clk, out);

	input clk;
	output [1:0] out;
	
	reg [3:0] counter;
	
	always @ (posedge clk) begin
		counter <= counter + 4'd1;
	end
	
	xnor(out[0], counter[3], counter[1]);
	xnor(out[1], counter[2], counter[0]);
	
endmodule