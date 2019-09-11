//Modulo para divisão
//Algortimo do livro computer organization and desing interface hardware/software
//Autores Crystal e Havallon
// 25/11/2017
module div (dataa, datab, result, clk, clk_en, start, reset, done);
	
	input [31:0] dataa;
	input [31:0] datab;
	input clk;
	input clk_en;
	input start;
	input reset;
	
	output reg [31:0] result;
	output reg done;
	
	reg [31:0] quociente;
	reg [63:0] divisor;
	reg [63:0] resto;
	
	localparam idle = 2'b00, calculando = 2'b01, pronto = 2'b11;
	
	reg [1:0] state;
	reg [1:0] substate;
	reg [5:0] contador;
	
	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			result    <= 31'd0;
			done      <= 1'b0;
			quociente <= 32'd0;
			divisor   <= 64'd0;
			resto     <= 64'd0;
			state     <= idle;
			substate  <= 2'd0;
			contador  <= 6'd0;
		end else begin
			if (clk_en) begin
				case(state)
				idle:begin
					done <= 1'b0;
					if (start)begin
						state          <= calculando;
						resto          <= dataa;
						divisor[63:32] <= datab;
						substate       <= 2'b00;
						quociente      <= 32'd0;
						contador       <= 6'd0;
					end else begin
						state <= idle;
					end
				end
				calculando:begin
					if (contador == 6'd33) begin
						state    <= pronto;
						contador <= 6'd0;
					end else begin
						case (substate)
							2'b00:begin
								resto    <= resto - divisor;
								substate <= 2'b01;
							end
							2'b01:begin
								if (resto[63] == 1'b1)begin
										resto    <= resto + divisor;
										substate <= 2'b10;
								end else begin
									substate <= 2'b11;
								end
								quociente <= quociente << 1;
							end
							2'b10:begin
								divisor  <= divisor >> 1;
								contador <= contador + 6'd1;
								substate <= 2'b00;
							end
							2'b11:begin
								substate     <= 2'b10;
								quociente[0] <= 1'b1;
							end
						endcase
					end
				end
				pronto:begin
					result <= quociente;
					done   <= 1'b1;
					state  <= idle;
				end
				endcase
			end
		end
	end
	
endmodule