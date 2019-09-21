#PonG
.data
	.equ START, 0x50a0
	.equ P1X, 0x5090
	.equ P1Y, 0x5080
	.equ P2X, 0x5070
	.equ P2Y, 0x5060
	.equ BX, 0x5050
	.equ BY, 0x5040
	.equ PLAYER1, 0x5010
	.equ PLAYER2, 0x5000
	.equ RND, 0x5020
	.equ UART, 0x50b0
.text

.global main
# Envia uma instrução para o LCD
.macro instr db
	custom 1, r0, r0, \db
.endm
# Envia um dado para o LCD
.macro data db
	movi r1, 1
	custom 1, r0, r1, \db
.endm

# Rotina principal de inicialização
main:
	#call initLCD
	#call GET_CHAR

	call resetBall 	# Inicializa a bolla (Centraliza)
	call resetBarra # Inicializa as barras (Centraliza)
	call initLCD	# Inicializa o LCD
	call menu		# Exibe o menu no LCD
	
	#Inicializa alguns registradores
	movia r11, START
	movi r7, 3  # velocidade em x
	movi r8, 3   # velicodade em y
	mov r9, r0   # score jogador 1
	mov r10, r0  # score jogador 2

# Espera que o usuario clique no botão de start e começa o gameloop
wait:
	ldwio r2, 0(r11)
	beq r2, r0, wait
	movi r2, 1
	instr r2	
	call placar # Exibe o placar no LCD (0 x 0)

#Looping de funcionamento do jogo.
#realiza todas as funções pertinentes ao
#jogo tais como o tratamento das colisões
#e as movimentações da bola e barras.
gameLoop:
	call moverBarra
	call moveBall
	call PlayersCollision
	call wallCollision
	custom 3, r1, r1, r1
	br gameLoop

# Rotinas referentes a bola ----------------------------------------------------------------
# Envia para o módulo VGA a posição em que deve-se desenhar a bola
moveBall:
	add r5,r5,r7		# Add posição x da bola + velocidade horizontal (x) atual
	add r6,r6,r8		# Add posição y da bola + velocidade vertical (y) atual
	movia r12, BX
	stwio r5, 0(r12)	# Salva a posição x atualizada (r5) no endereço de memória x da bola
	movia r12, BY
	stwio r6, 0(r12)	# Salva a posição y atualizada (r6) no endereço de memória y da bola
	ret

# Reseta a posição da bola centralizando-a.
resetBall:
	movia r12, BX
	movi r4, 316
	stwio r4, 0(r12)
	movia r12, BY
	movi r4, 236
	stwio r4, 0(r12)
	movi r5, 316 # Centro X da bola
	movi r6, 236 # Centro Y da bola	
	ret
# ------------------------------------------------------------------------------------------

# Rotinas referentes as barras -------------------------------------------------------------
# Centraliza a barra (Usado somente na inicialização do sistema.)
resetBarra:
	#Valor para centralizar barras
	movi r2, 196
	
	# Barra Player 1 (Esquerda)
	movi r3, 5 			# Eixo x fixo para a barra
	movia r13, P1X 		
	stwio r3, 0(r13)	# Salva o valor do centro X (r2) na memória da barra 1
	movia r13, P1Y
	stwio r2, 0(r13)	# Salva o valor do centro Y (r2) na memória da barra 1
	
	# Barra Player 2 (Direita)
	movia r3, 620 		# Eixo x fixo para a barra
	movia r13, P2X
	stwio r3, 0(r13)	# Salva o valor do centro X (r2) na memória da barra 2
	movia r13, P2Y
	stwio r2, 0(r13)	# Salva o valor do centro Y (r2) na memória da barra 1
	ret

# Realiza a movimentação da barra de acordo com o posicionamento do potenciometro, 
# após isso envia para o módulo VGA a posição da barra para o mesmo desenhar na tela
moverBarra:
	#Valores da barra: Min: 8 Max: 392
	stw ra, 4(sp)	# Guarda o contexto de retorno do fluxo de execução

	call GET_CHAR	# Chama label de leitura da UART para ler os valores dos potenciometros
	movi r3, 0x41
	beq r17, r3, valorP1 # Verifica se o valor lido é um "A", se for, chama label que verifica qual número lido para o jogador 1
	movi r3, 0x42
	beq r17, r3, valorP2 # Verifica se o valor lido é um "B", se for, chama a label que verifica qual número lido para o jogador 2
	br gameLoop

# Verifica qual valor recebido do potênciometro (0 - 9) + 1 e guarda a porcentagem do valor Y da tela
valorP1:
	mov r4, r18
	call GET_CHAR
	movi r3, 0x30
	bne r17, r3, p1veri1 #verifica se o valor recebido é 0 e salva 10% do valor total de X no registrador
	movi r18, 8
	br trataDadosP1  
p1veri1:
	movi r3, 0x31
	bne r17, r3, p1veri2 #verifica se o valor recebido é 1 e salva 20% do valor total de X no registrador
	movi r18, 76
	br trataDadosP1
p1veri2:
	movi r3, 0x32
	bne r17, r3, p1veri3 #verifica se o valor recebido é 2 e salva 30% do valor total de X no registrador
	movi r18, 115
	br trataDadosP1
p1veri3:
	movi r3, 0x3
	bne r17, r3, p1veri4 #verifica se o valor recebido é 3 e salva 40% do valor total de X no registrador
	movi r18, 153
	br trataDadosP1
p1veri4:
	movi r3, 0x34
	bne r17, r3, p1veri5 #verifica se o valor recebido é 4 e salva 50% do valor total de X no registrador
	movi r18, 192
	br trataDadosP1
p1veri5:
	movi r3, 0x35
	bne r17, r3, p1veri6 #verifica se o valor recebido é 5 e salva 60% do valor total de X no registrador
	movi r18, 230
	br trataDadosP1
p1veri6:
	movi r3, 0x36
	bne r17, r3, p1veri7 #verifica se o valor recebido é 6 e salva 70% do valor total de X no registrador
	movi r18, 268
	br trataDadosP1
p1veri7:
	movi r3, 0x37
	bne r17, r3, p1veri8 #verifica se o valor recebido é 7 e salva 80% do valor total de X no registrador
	movi r18, 307
	br trataDadosP1
p1veri8:
	movi r3, 0x38
	bne r17, r3, p1veri9 #verifica se o valor recebido é 8 e salva 90% do valor total de X no registrador
	movi r18, 345
	br trataDadosP1
p1veri9:
	movi r3, 0x39
	bne r17, r3, gameLoop #valorP1 #verifica se o valor recebido é 9 e salva 100% do valor total de X no registrador
	movi r18, 392
	br trataDadosP1

# Verifica qual valor recebido do potênciometro (0 - 9) + 1 e guarda a porcentagem do valor Y da tela
valorP2:
	mov r13, r19
	call GET_CHAR
	movi r3, 0x30
	bne r17, r3, p2veri1 #verifica se o valor recebido é 0 e salva 10% do valor total de Y no registrador
	#movi r2, 1
	movi r19, 8
	br trataDadosP2  
p2veri1:
	movi r3, 0x31
	bne r17, r3, p2veri2 #verifica se o valor recebido é 1 e salva 20% do valor total de Y no registrador
	#movi r2, 2
	movi r19, 76
	br trataDadosP2
p2veri2:
	movi r3, 0x32
	bne r17, r3, p2veri3 #verifica se o valor recebido é 2 e salva 30% do valor total de Y no registrador
	#movi r2, 3
	movi r19, 115
	br trataDadosP2
p2veri3:
	movi r3, 0x33
	bne r17, r3, p2veri4 #verifica se o valor recebido é 3 e salva 40% do valor total de Y no registrador
	#movi r2, 4
	movi r19, 153
	br trataDadosP2
p2veri4:
	movi r3, 0x34
	bne r17, r3, p2veri5 #verifica se o valor recebido é 4 e salva 50% do valor total de Y no registrador
	#movi r2, 5
	movi r19, 192
	br trataDadosP2
p2veri5:
	movi r3, 0x35
	bne r17, r3, p2veri6 #verifica se o valor recebido é 5 e salva 60% do valor total de Y no registrador
	#movi r2, 6
	movi r19, 230
	br trataDadosP2
p2veri6:
	movi r3, 0x36
	bne r17, r3, p2veri7 #verifica se o valor recebido é 6 e salva 70% do valor total de Y no registrador
	#movi r2, 7
	movi r19, 268
	br trataDadosP2
p2veri7:
	movi r3, 0x37
	bne r17, r3, p2veri8 #verifica se o valor recebido é 7 e salva 80% do valor total de Y no registrador
	#movi r2, 8
	movi r19, 307
	br trataDadosP2
p2veri8:
	movi r3, 0x38
	bne r17, r3, p2veri9 #verifica se o valor recebido é 8 e salva 0% do valor total de Y no registrador
	#movi r2, 9
	movi r19, 345
	br trataDadosP2
p2veri9:
	movi r3, 0x39
	bne r17, r3, gameLoop #valorP2 #verifica se o valor recebido é 9 e salva 100% do valor total de Y no registrador
	#movi r2, 10
	movi r19, 392

trataDadosP1:
# Faz o tratamento dos valores lidos do potenciometro através da UART
	#movi r13, P1Y
	#ldwio r4, 0(r13) 	# Pega o valor atual de Y da barra 1
	
	bgt r18, r4, estSubidaP1 # Compara de o valor do potenciometro é maior que o da barra
	blt r18, r4, estDescidaP1 # Compara se o valor do potenciometro é menor que o da barra
	mov r18, r4
	br setBarra1

trataDadosP2:
	#movia r13, P2Y
	#ldwio r4, 0(r13)
	
	bgt r19, r13, estSubidaP2
	blt r19, r13, estDescidaP2
	mov r19, r13
	br setBarra2

estSubidaP1:
	addi r18, r4, 3
	br setBarra1
estSubidaP2:
	addi r19, r13, 3
	br setBarra2

estDescidaP1:
	subi r18, r4, 3
	br setBarra1
estDescidaP2:
	subi r19, r13, 3
	br setBarra2

setBarra1:
	# Barra Player 1 (Esquerda)
	movia r3, 5 			# Eixo x fixo para a barra
	movia r4, P1X
	stwio r3, 0(r4)
	movia r4, P1Y
	stwio r18, 0(r4) 	# Salva a porcentagem referente ao valor lido do potenciometro no endereço P1Y para leitura do VGA
	
	ldwio ra, 4(sp) # Ler o contexto de retorno do fluxo de execução
	ret
setBarra2:
	# Barra Player 2 (Direita)
	movia r3, 620 		# Eixo x fixo para a barra
	movia r13, P2X
	stwio r3, 0(r13)
	movia r13, P2Y
	stwio r19, 0(r13)	# Salva a porcentagem referente ao valor lido do potenciometro no endereço P2Y para a leitura do VGA

	ldwio ra, 4(sp) # Ler o contexto de retorno do fluxo de execução
	ret
# ------------------------------------------------------------------------

# Rotinas de colisões ----------------------------------------------------
# Verifica se a bola chegou na posião x da barra 1 ou 2, e entra no label referente a colisão ocorrida.
PlayersCollision:
	movi r1, 610 # X da barra 2
	mov r12, r5   # X da bola
	addi r12, r12, 4
	bge r12, r1, verificarBarra2
	
	movi r1, 10 # X da barra 1
	subi r12, r12, 8 # X da bola
	bge r1, r12, verificarBarra1
	ret

# Pega o valor obtido pelo potenciometro para o y da tela e assim retorna a colisão ou não
verificarBarra1:
	add r4, r0, r6
	bge r4, r18, tamanhoBarra1
	ret

# Pega o valor pego pelo potenciometro para o y da tela e assim retorna a colisão ou não
verificarBarra2:
	add r4, r0, r6
	bge r4, r19, tamanhoBarra2
	ret

# Ao colidir com a barra, dependendo da posição entra em um hit diferente
tamanhoBarra1:
	addi r1, r1, 16
	bge r1, r12, _hit1
	addi r1, r1, 16
	bge r1, r12, _hit2
	addi r1, r1, 16
	bge r1, r12, _hit3
	addi r1, r1, 16
	bge r1, r12, _hit4
	addi r1, r1, 16
	bge r1, r12, _hit5
	ret

# Ao colidir com a barra, dependendo da posição entra em um hit diferente
tamanhoBarra2:
	addi r1, r1, 16
	bge r1, r12, hit1
	addi r1, r1, 16
	bge r1, r12, hit2
	addi r1, r1, 16
	bge r1, r12, hit3
	addi r1, r1, 16
	bge r1, r12, hit4
	addi r1, r1, 16
	bge r1, r12, hit5
	ret
# ------------------------------------------------------------------------

#HIT BARRA DIREITA
hit1:
    movia r14, RND		# Random
	ldwio r1, 0(r14)
	mov r2, r0
	beq r1, r2, zero
	addi r2,r2,1
	beq r1, r2, um
	addi r2,r2,1
	beq r1, r2, dois
	addi r2,r2,1
	beq r1, r2, tres
	ret
hit2:
    movi r7, -3
    movi r8, -3
	ret
hit3:
    movi r8, 0
    movi r7, -3
        ret 
hit4:
    movi r7, -3
    movi r8, 3
	ret
hit5:
	movia r14, RND
	ldwio r1, 0(r14)
	mov r2, r0
	beq r1, r2, zero
	addi r2,r2,1
	beq r1, r2, um
	addi r2,r2,1
	beq r1, r2, dois
	addi r2,r2,1
	beq r1, r2, tres
	ret

#HIT BARRA DIREITA
_hit1:
    movia r14, RND
	ldwio r1, 0(r14)
	mov r2, r0
	beq r1, r2, _zero
	addi r2,r2,1
	beq r1, r2, _um
	addi r2,r2,1
	beq r1, r2, _dois
	addi r2,r2,1
	beq r1, r2, _tres
	ret
_hit2:
    movi r7, 3
    movi r8, -3
	ret
_hit3:
    movi r8, 0
    movi r7, 3
	ret 
_hit4:
    movi r7, 3
    movi r8, 3
	ret
_hit5:
	movia r14, RND
	ldwio r1, 0(r14)
	mov r2, r0
	beq r1, r2, _zero
	addi r2,r2,1
	beq r1, r2, _um
	addi r2,r2,1
	beq r1, r2, _dois
	addi r2,r2,1
	beq r1, r2, _tres
	ret

#Indo pra esquerda
zero:
	movi r8, 0
	movi r7, -3
	ret
um:
	movi r7, -3
	movi r8, -3
	ret
dois:
	movi r7, -1
	movi r8, -3
	ret
tres:
	movi r7, -3
	movi r8, -1
	ret

#Indo pra direita
_zero:
	movi r8, 0
	movi r7, 3
	ret
_um:
	movi r7, 3
	movi r8, 3
	ret
_dois:
	movi r7, 1
	movi r8, 3
	ret
_tres:
	movi r7, 3
	movi r8, 1
	ret

# Ao realizar uma colisão em qualquer parte da parede entra em uma parte diferente
wallCollision:
	movi r1, 471
	mov r2, r6		# Add em r2 o valor atual de y da bola
	addi r2,r2,4
	bge r2, r1, changeDownWall	# Verifica se o valor y da bola é igual ou maior que o limite inferior da tela, se sim, colisão inferior
	movi r1, 610
	mov r2, r5		# Add em r2 o valor atual de x da bola
	addi r2, r2, 4
	bge r2, r1, changeRightWall	# Verifica se o valor x da bola é igual ou maior que o limite direito da tela, se sim, colisão com parede da esquerda  
	movi r1, 8
	mov r2, r6		# Add em r2 o valor atual do y da bola
	subi r2, r2, 4
	bge r1, r2, changeDownWall	# Verifica se o valor de y da bola é igual ou maior que o limite superior da tela, se sim, colisão superior
	movi r1, 8
	mov r2, r5		# Add em r2 o valor atual do x da bola
	subi r2, r2, 4
	bge r1, r2, changeLeftWall	# Verifica se o valor x da bola é igual ou menor que o limite esquerdo da tela, se sim, colisão com parede da direita
	ret
# Ao ocorrer a colisão em uma das paredes, adiciona um ponto para o jogador caso o mesmo nao tenha atingido 5 pontos.
# Ao atingir 5 é dada a vitoria!
changeRightWall:
	addi r9, r9, 1		# Incrementa pontuação do jogador 1
	movi r1, 9
	beq r1, r9, win1	# Compara se o jogador 1 ganhou (atingiu 9 gols)
	addi r3, r9, 48
	movi r1, 0x8a
	instr r1
	data r3
	movi r7, 3			# Reseta velocidade X da bola
	mov r8, r7			# Reseta velocidade Y da bola
	br resetBall

changeLeftWall:
	addi r10, r10, 1 	# Incrementa pontuação do jogador 1
	movi r1, 9
	beq r1, r10, win2	# Compara se o jogador 2 ganhou (atingiu 9 gols)
	addi r3, r10, 48
	movi r1, 0xca
	instr r1
	data r3
	movi r7, 3			# Reseta velocidade X da bola
	mov r8, r7			# Reseta velocidade Y da bola
	br resetBall

# Ao bater na parede de cima ou baixo, retorna no mesmo angulo de entrada
changeDownWall:
	movi r1, -1
	custom 2, r8,r8,r1
	ret

# GAME OVER --------------------------------------------------------------
#espera o botao de start para começar o jogo novamente
gameOver:
	ldwio r4, 0(r11)
	beq r4, r0, gameOver
	movi r2, 1
	instr r2
	call menu
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	custom 3, r1,r1,r1
	call resetBall 	# Centraliza a bola
	call resetBarra # Centraliza as barras
	# Reseta a velocidade
	movi r7, 3  	# velocidade em x
	movi r8, 3   	# velicodade em y
	# Reseta as pontuações dos jogadores
	mov r9, r0   	# pontos jogador 1
	mov r10, r0  	# pontos jogador 2
	br wait
# ------------------------------------------------------------------------

# Rotinas do display LCD -------------------------------------------------

#Inicialização do display lcd
initLCD:
	movi r2, 0x30
	instr r2	
	movi r2, 0x30
	instr r2
	movi r2, 0x39
	instr r2
	movi r2, 0x14
	instr r2
	movi r2, 0x56
	instr r2
	movi r2, 0x6d
	instr r2
	movi r2, 0x0c
	instr r2
	movi r2, 0x06
	instr r2
	movi r2, 0x01
	instr r2
	ret

# Exibe o Menu no display LCD
menu:
	movi r2, 0x1
	instr r2
	#movi r2, 0x84
	#instr r2
	movi r2, 0x42 #B
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x73 #s
 	data r2
	movi r2, 0x69 #i
 	data r2
	movi r2, 0x6c #l
 	data r2
	movi r2, 0x65 #e
 	data r2
	movi r2, 0x69 #i
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x20 #
 	data r2
	movi r2, 0x50 #P
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x6e #n
 	data r2
	movi r2, 0x47 #G
 	data r2

	movi r2, 0xc3
	instr r2
	movi r2, 0x50 #P
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x65 #e
 	data r2
	movi r2, 0x73 #s
 	data r2
	movi r2, 0x73 #s
 	data r2
	movi r2, 0x20 # 
 	data r2
	movi r2, 0x53 #S
 	data r2
	movi r2, 0x74 #t
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x74 #t
 	data r2
	ret

#Exibindo o placar no display
placar:
	movi r2, 0x80
	instr r2 
	movi r2, 0x4a #J
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x67 #g
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x64 #d
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x20 # 
 	data r2
	movi r2, 0x31 #1
 	data r2
	movi r2, 0x3a #:
 	data r2
	movi r2, 0x30 #0
 	data r2
	
	movi r2, 0xc0
	instr r2 
	movi r2, 0x4a #J
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x67 #g
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x64 #d
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x20 # 
 	data r2
	movi r2, 0x32 #2
 	data r2
	movi r2, 0x3a #:
 	data r2
	movi r2, 0x30 #0
 	data r2
	ret

#Escreve no lcd a vitória do jogador 1
win1:
	movi r2, 0x1
	instr r2
	movi r2, 0x84
	instr r2
	
	movi r2, 0x4a #J
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x67 #g
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x64 #d
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x20 # 
 	data r2
	movi r2, 0x31 #1
 	data r2

	movi r2, 0xc5
	instr r2
	movi r2, 0x47 #G
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x6e #n
 	data r2
	movi r2, 0x68 #h
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x75 #u
 	data r2
	movia r11, START
	br gameOver
#escreve no lcd a vitoria do jogador 2
win2:
	movi r2, 0x1
	instr r2
	movi r2, 0x84
	instr r2
	
	movi r2, 0x4a #J
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x67 #g
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x64 #d
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x72 #r
 	data r2
	movi r2, 0x20 # 
 	data r2
	movi r2, 0x32 #2
 	data r2

	movi r2, 0xc5
	instr r2
	movi r2, 0x47 #G
 	data r2
	movi r2, 0x61 #a
 	data r2
	movi r2, 0x6e #n
 	data r2
	movi r2, 0x68 #h
 	data r2
	movi r2, 0x6f #o
 	data r2
	movi r2, 0x75 #u
 	data r2
	movia r11, START
	br gameOver

# ------------------------------------------------------------------------

# Rotina para ler um caractere da RS232 UART.
   # r6 = endereço base RS232 UART
   # Retorna o caractere em r2. Retorna "\ 0" se não houver novo caractere na fila RX FIFO.
GET_CHAR:
   #call delay
   #stw ra, 8(sp)					 # Salva o contexto
   movi r15, UART
   
   ldwio r17, 0(r15)                 # read the RS232 UART Data register 
   andi r16, r17, 0x8000             # check if there is new data 
   bne r16, r0, RETURN_CHAR
   mov r17, r0                      # if no new data, return ‘\0’ 
RETURN_CHAR:
   andi r16, r17, 0x00ff             # the data is in the least significant byte 
   mov r17, r16                      # set r17 with the return value 
   #ldwio ra, 8(sp)
   
   #movi r2, 0x1
   #instr r2

   #data r17
   #custom 3, r1,r1,r1

   #br GET_CHAR
FIM_CHAR:
   #bne r17, zero, GET_CHAR          # Verifica se r17 é diferente de 0, caso seja ainda existem dados para ser lidos na uart
   ret
#----------------------------------------------------------------

end:
	br end
	.end