module vgaPxlGen (clk, frame_pulse, rst, pxl_en, x, y, r, g, b);

	input clk;
	input rst;
	input pxl_en;
	input frame_pulse;
	input [9:0]  x;
	input [9:0] y;
	
	output reg r;
	output reg g;
	output reg b;
	
	// Deizando a tela vermelha
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			r <= 1'b0;
			g <= 1'b0;
			b <= 1'b0;
		end else begin
			if (pxl_en) begin
				r <= 1'b1;
				g <= 1'b0;
				b <= 1'b0;
			end else begin
				r <= 1'b0;
				g <= 1'b0;
				b <= 1'b0;
			end
		end
	end
	
endmodule