module uart (clock_50MHz, KEY, LEDM_R,LEDM_C, UART_Rx, UART_Tx);

	input clock_50MHz;
	input [11:0] KEY;
	input UART_Rx;
	
	output [7:0] LEDM_R;
	output [4:0] LEDM_C;
	output UART_Tx;

	wire [7:0] out;
	
	assign LEDM_R = ~out;
	assign LEDM_C = 5'b11110;
	
	nios u0 (
		.clk_clk                        (clock_50MHz),                        //                        clk.clk
		.reset_reset_n                  (~KEY[0]),                  //                      reset.reset_n
		.led_external_connection_export (out), //    led_external_connection.export
		.uart_0_external_connection_rxd (UART_Rx), // uart_0_external_connection.rxd
		.uart_0_external_connection_txd (UART_Tx)  //                           .txd
	);



endmodule