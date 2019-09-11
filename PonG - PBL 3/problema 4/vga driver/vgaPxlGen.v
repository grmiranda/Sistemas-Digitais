module vgaPxlGen (clk, clk50, frame_pulse, rst, pxl_en, x, y, r, g, b, x1, y1, x2, y2, xb, yb);

	input clk;
	input rst;
	input pxl_en;
	input frame_pulse;
	input [9:0]  x;
	input [9:0]  y;
	input clk50;
	
	input [9:0] x1;
	input [9:0] y1;
	
	input [9:0] x2;
	input [9:0] y2;
	
	input [9:0] xb;
	input [9:0] yb;
	
	output reg r;
	output reg g;
	output reg b;
	
	reg [9:0] p1X;
	reg [9:0] p1Y;
	
	reg [9:0] p2X;
	reg [9:0] p2Y;
	
	reg [9:0] bX;
	reg [9:0] bY;
	
	reg  [6:0] relY;
	wire [9:0] relX;
	
	reg  [4:0] relYB;
	wire [8:0] relXB;
	
	barrasprite Barra (
		.address(relY),
		.clock(clk50),
		.q(relX)
	);
	
	bolasprite bola(
		.address(relYB),
		.clock(clk50),
		.q(relXB)
	);
	
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			p1X <= 10'd0;
			p1Y <= 10'd0;
			p2X <= 10'd0;
			p2Y <= 10'd0;
			bX  <= 10'd0;
			bY  <= 10'd0;
		end else begin
			if (frame_pulse) begin
				p1X <= x1;
				p1Y <= y1;
				p2X <= x2;
				p2Y <= y2;
				bX  <= xb;
				bY  <= yb;
			end
		end
	end
	
	// Deizando a tela vermelha
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			r     <= 1'b0;
			g     <= 1'b0;
			b     <= 1'b0;
			relY  <= 7'd0;
			relYB <= 5'd0;
		end else begin
			if (pxl_en) begin
				if(x >= p1X && x < p1X+10 && y >= p1Y && y < p1Y + 80)begin
					relY <= y - p1Y;
					r <= relX[9 - (x-p1X)];
					g <= relX[9 - (x-p1X)];
					b <= relX[9 - (x-p1X)];
				end else if (x >= p2X && x < p2X+10 && y >= p2Y && y < p2Y + 80) begin
					relY <= y - p2Y;
					r <= relX[9 - (x-p2X)];
					g <= relX[9 - (x-p2X)];
					b <= relX[9 - (x-p2X)];
				end else if (x >= bX-4 && x < bX+4 && y >= bY-4 && y < bY + 4) begin
					relYB <= y - bY + 5'd4;
					r <= relXB[8 - (x-bX+5'd4)];
					g <= relXB[8 - (x-bX+5'd4)];
					b <= relXB[8 - (x-bX+5'd4)];
				end else if (y < 8 || y > 471) begin
					r <= 1'b1;
					b <= 1'b1;
					g <= 1'b1;
				end else begin
					r <= 1'b0;
					b <= 1'b0;
					g <= 1'b0;
				end
			end else begin
				r <= 1'b0;
				g <= 1'b0;
				b <= 1'b0;
			end
		end
	end
	
endmodule