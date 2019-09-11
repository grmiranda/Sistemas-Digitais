//CONVERSOR ADC MAX 1379 SPI 
// Havallon
// 03/12/17

module AD (rst, clk, cnvst, cs, out0, refsel, sclk, sd, ub, sel, data_o);

	input rst;
	input clk;
	input out0;
	
	output reg cnvst;
	output cs;
	output refsel;
	output reg sclk;
	output sd;
	output ub;
	output sel;
	output reg [11:0] data_o;
	
	assign refsel = 1'b0;
	assign cs     = 1'b0;
	assign sd     = 1'b0;
	assign ub     = 1'b0;
	assign sel    = 1'b0;
	
	reg [1:0] counter;
	reg [2:0] latencia;
	reg [4:0] timing;
	reg [4:0] pulsos;
	reg [11:0] data;
	
	//Gerando o pulso de SCLK de 8.333MHz
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			sclk    <= 1'b0;
			counter <= 2'd0;
		end else begin
			if (counter == 2'd3) begin
				sclk <= ~sclk;
				counter <= 2'd0;
			end else begin
				counter <= counter + 2'd1;
			end
		end
	end
	
	
	always @ (posedge sclk or posedge rst) begin
	if (rst) begin
			cnvst    <= 1'b1;
			data     <= 12'd0;
			latencia <= 3'd0;
			timing   <= 5'd0;
			pulsos   <= 5'd0;
		end else begin
			if (cnvst) begin
				//gerando pulso para inciar uma nova conversÃ£o
				if (timing == 30) begin
					cnvst    <= 1'b0;
					timing   <= 5'd0;
					latencia <= 3'd0;
					pulsos   <= 5'd0;
				end else begin
					timing <= timing + 5'd1;
				end
			end else begin
				//verificando o 5 pulso para iniciar a leitura
				if (latencia == 4) begin
					if (pulsos == 13) begin
						data_o   <= data;
						pulsos   <= 5'd11;
						latencia <= 3'd0;
						cnvst    <= 1'b1;
					end else begin
						pulsos <= pulsos + 5'd1;
						data <= data << 1;
						data[0] <= out0;
					end
				end else begin
					latencia <= latencia + 1'd1;
				end
			end
		end
	end
	
endmodule