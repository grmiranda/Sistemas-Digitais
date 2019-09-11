module delay30fps (dataa, datab, result, clk, clk_en, start, reset, done);
	
	input [31:0] dataa;
	input [31:0] datab;
	input clk;
	input clk_en;
	input start;
	input reset;
	
	output reg [31:0] result;
	output reg done;
	
	reg [20:0] counter;
	reg state;
	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			counter <= 21'd0;
			done    <= 1'b0;
			result  <= 32'b0;
			state   <= 1'b0;
		end else begin
			if (clk_en) begin
				if(!state) begin
					done <= 1'b0;
					if (start) begin
						state   <= 1'b1;
						counter <= 21'd0;
					end
				end else begin
					if (counter == 21'd1_666_666) begin
						state <= 1'b0;
						done <= 1'b1;
					end else begin
						counter <= counter + 21'd1;
					end
				end
			end
		end
	end
	
endmodule