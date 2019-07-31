module top (
	input clk,
	input [3:0] buttons,
	output [3:0] leds,
	output en,
	output rw,
	output rs,
	output [7:0] db,
	input rx,
	output tx
);

	 proj_qsys u0 (
        .clk_clk                            (clk),    //                            clk.clk
        .buttons_external_connection_export (buttons),// buttons_external_connection.export
        .leds_external_connection_export    (leds), 	//    leds_external_connection.export
        .en_export                          (en), 		//                          en.export
        .rw_export                          (rw),     //                          rw.export
        .rs_export                          (rs),     //                          rs.export
        .db_export                          (db),     //                          db.export
		  .rs232_RXD                          (rx),     //                          rs232.RXD
        .rs232_TXD                          (tx)      // 								 rs232.TXD
    );

endmodule