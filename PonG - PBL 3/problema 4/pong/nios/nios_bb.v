
module nios (
	busy_export,
	bx_export,
	by_export,
	clk_clk,
	jogador1_export,
	jogador2_export,
	lcd_out_rs,
	lcd_out_rw,
	lcd_out_en,
	lcd_out_db,
	p1x_export,
	p1y_export,
	p2x_export,
	p2y_export,
	random_export,
	start_export);	

	input		busy_export;
	output	[9:0]	bx_export;
	output	[9:0]	by_export;
	input		clk_clk;
	input		jogador1_export;
	input		jogador2_export;
	output		lcd_out_rs;
	output		lcd_out_rw;
	output		lcd_out_en;
	output	[7:0]	lcd_out_db;
	output	[9:0]	p1x_export;
	output	[9:0]	p1y_export;
	output	[9:0]	p2x_export;
	output	[9:0]	p2y_export;
	input	[1:0]	random_export;
	input		start_export;
endmodule
