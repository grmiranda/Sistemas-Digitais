
module nios (
	clk_clk,
	reset_reset_n,
	led_export,
	rs232_rxd,
	rs232_txd);	

	input		clk_clk;
	input		reset_reset_n;
	output	[7:0]	led_export;
	input		rs232_rxd;
	output		rs232_txd;
endmodule
