module pbl3(clock_50MHz, KEY, LEDM_C, LEDM_R, UART_Rx, UART_Tx);

	input clock_50MHz;
	input [11:0] KEY;
	input UART_Rx;
	
	output [4:0] LEDM_C;
	output [7:0] LEDM_R;
	output UART_Tx;
	
	assign LEDM_C = 5'b11110;
	assign LEDM_R = ~led;
	
	wire [7:0] led;
	
	nios u0 (
		.clk_clk       (clock_50MHz),       //   clk.clk
		.reset_reset_n (~KEY[0]), // reset.reset_n
		.led_export    (led),    //   led.export
		.rs232_rxd     (UART_Rx),     // rs232.rxd
		.rs232_txd     (UART_Tx)      //      .txd
	);


endmodule