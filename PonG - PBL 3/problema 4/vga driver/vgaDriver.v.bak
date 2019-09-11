//VGA DRIVER
// Crystal & Havallon
// 02/12/2017
module vgaDriver(clk, rst, hsync, vsync, r, g, b);
	
	input clk;
	input rst;
	
	output hsync;
	output vsync;
	output [3:0] r;
	output [3:0] g;
	output [3:0] b;
	
	wire [9:0] x;
	wire [9:0] y;
	wire en;
	
	wire rr;
	wire gg;
	wire bb;
	
	wire frame_pulse;
	
	wire clk25;
	
	assign vsync = frame_pulse;
	assign r = {rr,rr,rr,rr};
	assign g = {gg,gg,gg,gg};
	assign b = {bb,bb,bb,bb};
	
	clk50to25 clk50to25 (
		.rst(rst),
		.clk_in(clk),
		.clk_out(clk25)
	);
	
	vgaSync vgaSync(
		.clk(clk25),
		.rst(rst),
		.hsync(hsync),
		.vsync(frame_pulse),
		.hpos(x),
		.vpos(y),
		.pxl_en(en)
	);
	
	vgaPxlGen vgaPxlGen (
		.clk(clk25),
		.frame_pulse(frame_pulse),
		.rst(rst),
		.pxl_en(en),
		.x(x),
		.y(y),
		.r(rr),
		.g(gg),
		.b(bb)
	);
	
endmodule