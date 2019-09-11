//Modulo para multiplicao
//Algortimo do livro computer organization and desing interface hardware/software
//Autores Crystal e Havallon
// 25/11/2017
module mul (dataa, datab, result, clk, clk_en, start, reset, done);

	input [31:0] dataa;
	input [31:0] datab;
	input clk;
	input clk_en;
	input start;
	input reset;
	
	output reg [31:0] result;
	output reg done;
	
	reg [63:0] multiplicando;
	reg [31:0] multiplicador;
	reg [63:0] produto;
	
	reg [5:0] contador;
	reg trigger;
	
	localparam idle = 2'b00, calculando = 2'b01, pronto = 2'b11;
	
	reg [1:0] state;
	
	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			result        <= 32'd0;
			done          <= 1'b0;
			multiplicando <= 64'd0;
			multiplicador <= 32'd0;
			produto       <= 64'd0;
			contador      <= 6'd0;
			trigger       <= 1'b0;
			state         <= idle;
		end else begin
			if (clk_en) begin
				case (state)
					idle:begin
						done <= 1'b0;
						if (start) begin
							state <= calculando;
							multiplicando <= dataa;
							multiplicador <= datab;
							produto       <= 64'd0;
							trigger       <= 1'b0;
							contador      <= 6'd0;
						end else begin
							state <= idle;
						end
					end
					calculando:begin
						if (contador == 6'd32) begin
							state <= pronto;
							contador <= 6'd0;
						end else begin
							if (!trigger)begin
								if (multiplicador[0] == 1'b1) begin
									produto <= produto + multiplicando;
								end
								trigger <= 1'b1;
							end else begin
								multiplicando <= multiplicando << 1;
								multiplicador <= multiplicador >> 1;
								trigger <= 1'b0;
								contador <= contador + 6'd1;
							end
						end
					end
					pronto:begin
						state <= idle;
						done  <= 1'b1;
						result <= produto;
					end
				endcase
			end
		end
	end

endmodule