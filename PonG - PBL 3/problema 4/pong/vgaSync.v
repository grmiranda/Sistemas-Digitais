//VGA Sincronizador
// Crystal & Havallon
// 02/12/2017
module vgaSync(clk, rst, hsync, vsync, hpos, vpos, pxl_en);

	input clk;
	input rst;
	
	output reg hsync;
	output reg vsync;
	
	output reg [9:0] hpos;
	output reg [9:0] vpos;
	
	output reg pxl_en;
	
	localparam hva = 640;
	localparam hfp = 16;
	localparam hsp = 96;
	localparam hbp = 48;
	
	localparam vva = 480;
	localparam vfp = 11;
	localparam vsp = 2;
	localparam vbp = 31;
	
	// Pecorrendo a tela, pixel por pixel
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			hpos   <= 10'd0;
			vpos   <= 10'd0;
		end else begin
			if (hpos < (hva + hfp + hsp + hbp)) begin
				hpos <= hpos + 10'd1;
			end else begin
				hpos <= 10'd0;
				if (vpos < (vva + vfp + vsp + vbp)) begin
					vpos <= vpos + 10'd1;
				end else begin
					vpos <= 10'd0;
				end
			end
		end
	end
	
	// Gerando a sincronia horizontal e vertical
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			hsync  <= 1'b0;
			vsync  <= 1'b0;
		end else begin
			if ((hpos > (hva + hfp)) && (hpos <(hva + hfp +hsp))) begin
				hsync <= 1'b0;
			end else begin
				hsync <= 1'b1;
			end
			
			if ((vpos > (vva + vfp)) && (vpos < (vva + vfp +vsp))) begin
				vsync <= 1'b0;
			end else begin
				vsync <= 1'b1;
			end
		end
	end
	
	// Definindo a area visivel
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			pxl_en <= 1'b0;
		end else begin
			if (hpos > hva || vpos > vva) begin
				pxl_en <= 1'b0;
			end else begin
				pxl_en <= 1'b1;
			end
		end
	end
	
endmodule