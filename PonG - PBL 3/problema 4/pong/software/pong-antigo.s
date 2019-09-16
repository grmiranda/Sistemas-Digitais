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
	call moveBall
	call moverBarra
	call PlayersCollision
	call wallCollision
	custom 3, r1, r1, r1
	br gameLoop

# Rotinas referentes a bola ----------------------------------------------------------------
# Envia para o módulo VGA a posição em que deve-se desenhar a bola
moveBall:
	add r5,r5,r7
	add r6,r6,r8
	movia r12, BX
	stwio r5, 0(r12)
	movia r12, BY
	stwio r6, 0(r12)
	ret

# Reseta a posição da bola centralizando-a.
resetBall:
	movia r12, BX
	movi r1, 316
	stwio r1, 0(r12)
	movia r12, BY
	movi r1, 236
	stwio r1, 0(r12)
	movi r5, 316 # X da bola
	movi r6, 236 # Y da bola	
	ret
# ------------------------------------------------------------------------------------------

# Rotinas referentes as barras -------------------------------------------------------------
# Centraliza a barra (Usado somente na inicialização do sistema.)
resetBarra:
	#Valor para centralizar barras
	movi r18, 196
	
	# Barra Player 1 (Esquerda)
	movi r3, 5 # Eixo x fixo para a barra
	movia r12, P1X
	stwio r3, 0(r12)
	movia r12, P1Y
	stwio r18, 0(r12)
	# Barra Player 2 (Direita)
	movia r3, 620 # Eixo x fixo para a barra
	movia r12, P2X
	stwio r3, 0(r12)
	movia r12, P2Y
	stwio r18, 0(r12)
	ret

# Realiza a movimentação da barra de acordo com o posicionamento do potenciometro, 
# após isso envia para o módulo VGA a posição da barra para o mesmo desenhar na tela
moverBarra:
	#Valores da barra: Min: 8 Max: 392
	#TA PERDENDO REFERENCIA DE RETORNO!!
	stw ra, 4(sp)
lerUART:
	call GET_CHAR
	movi r3, 0x41
	beq r17, r3, valorP1 #verifica se o valor lido é um "A"
	movi r3, 0x42
	beq r17, r3, valorP2 #verifica se o valor lido é um "B"
	br gameLoop

valorP1:
	call GET_CHAR
	movi r3, 0x30
	bne r17, r3, p1veri1 #verifica se o valor recebido é 0 e salva 1 no registrador
	movi r18, 38
	br fim_verip1  
p1veri1:
	movi r3, 0x31
	bne r17, r3, p1veri2 #verifica se o valor recebido é 1 e salva 2 no registrador
	movi r18, 76
	br fim_verip1
p1veri2:
	movi r3, 0x32
	bne r17, r3, p1veri3 #verifica se o valor recebido é 2 e salva 1 no registrador
	movi r18, 115
	br fim_verip1
p1veri3:
	movi r3, 0x3
	bne r17, r3, p1veri4 #verifica se o valor recebido é 3 e salva 4 no registrador
	movi r18, 153
	br fim_verip1
p1veri4:
	movi r3, 0x34
	bne r17, r3, p1veri5 #verifica se o valor recebido é 4 e salva 5 no registrador
	movi r18, 192
	br fim_verip1
p1veri5:
	movi r3, 0x35
	bne r17, r3, p1veri6 #verifica se o valor recebido é 5 e salva 6 no registrador
	movi r18, 230
	br fim_verip1
p1veri6:
	movi r3, 0x36
	bne r17, r3, p1veri7 #verifica se o valor recebido é 6 e salva 7 no registrador
	movi r18, 268
	br fim_verip1
p1veri7:
	movi r3, 0x37
	bne r17, r3, p1veri8 #verifica se o valor recebido é 7 e salva 8 no registrador
	movi r18, 307
	br fim_verip1
p1veri8:
	movi r3, 0x38
	bne r17, r3, p1veri9 #verifica se o valor recebido é 8 e salva 9 no registrador
	movi r18, 345
	br fim_verip1
p1veri9:
	movi r3, 0x39
	bne r17, r3, fim_verip1 #valorP1 #verifica se o valor recebido é 9 e salva 10 no registrador
	movi r18, 384
	br fim_verip1
fim_verip1:
	br trataDados
/*lerB:
	# ler B e dado do player 2
	call GET_CHAR
	movi r3, 0x42
	bne r17, r3, gameLoop #verifica se o valor lido é um "B"
*/
valorP2:
	call GET_CHAR
	movi r3, 0x30
	bne r17, r3, p2veri1 #verifica se o valor recebido é 0 e salva 1 no registrador
	#movi r2, 1
	movi r19, 38
	br fim_verip2  
p2veri1:
	movi r3, 0x31
	bne r17, r3, p2veri2 #verifica se o valor recebido é 1 e salva 2 no registrador
	#movi r2, 2
	movi r19, 76
	br fim_verip2
p2veri2:
	movi r3, 0x32
	bne r17, r3, p2veri3 #verifica se o valor recebido é 2 e salva 1 no registrador
	#movi r2, 3
	movi r19, 115
	br fim_verip2
p2veri3:
	movi r3, 0x33
	bne r17, r3, p2veri4 #verifica se o valor recebido é 3 e salva 4 no registrador
	#movi r2, 4
	movi r19, 153
	br fim_verip2
p2veri4:
	movi r3, 0x34
	bne r17, r3, p2veri5 #verifica se o valor recebido é 4 e salva 5 no registrador
	#movi r2, 5
	movi r19, 192
	br fim_verip2
p2veri5:
	movi r3, 0x35
	bne r17, r3, p2veri6 #verifica se o valor recebido é 5 e salva 6 no registrador
	#movi r2, 6
	movi r19, 230
	br fim_verip2
p2veri6:
	movi r3, 0x36
	bne r17, r3, p2veri7 #verifica se o valor recebido é 6 e salva 7 no registrador
	#movi r2, 7
	movi r19, 268
	br fim_verip2
p2veri7:
	movi r3, 0x37
	bne r17, r3, p2veri8 #verifica se o valor recebido é 7 e salva 8 no registrador
	#movi r2, 8
	movi r19, 307
	br fim_verip2
p2veri8:
	movi r3, 0x38
	bne r17, r3, p2veri9 #verifica se o valor recebido é 8 e salva 9 no registrador
	#movi r2, 9
	movi r19, 345
	br fim_verip2
p2veri9:
	movi r3, 0x39
	bne r17, r3, gameLoop #valorP2 #verifica se o valor recebido é 9 e salva 10 no registrador
	#movi r2, 10
	movi r19, 384
	br fim_verip2
fim_verip2:

trataDados:
# Faz o tratamento dos valores lidos do potenciometro através da UART
	#movia r12, PLAYER1
	#movia r13, PLAYER2
	#ldwio r1, 0(r12)
	#ldwio r2, 0(r13)
	#addi r1, r1, 1 			# pos + 1
	#addi r2, r2, 1
	#movi r3, 4
	#custom 0, r1, r1, r3 	# Chama a custom de divisão e faz: r1 = r1 / 4
	#custom 0, r2, r2, r3	
	#movi r3, 6
	#custom 2, r1, r1, r3 	# Chama a custom de multiplicação e faz: r1 = r1 * 6
	#custom 2, r2, r2, r3	
	#addi r1, r0, 220 #addi r1,r1, 7 		# Soma o valor de r1 com 7: r1 = r1 + 7
	#addi r2, r2, 372

	# Barra Player 1 (Esquerda)
	movi r3, 5 # Eixo x fixo para a barra
	movia r12, P1X
	stwio r3, 0(r12)
	movia r12, P1Y
	stwio r18, 0(r12)
	
	# Barra Player 2 (Direita)
	movia r3, 620 # Eixo x fixo para a barra
	movia r12, P2X
	stwio r3, 0(r12)
	movia r12, P2Y
	stwio r19, 0(r12)

	ldwio ra, 4(sp)
	ret

# ------------------------------------------------------------------------

# Rotinas de colisões ----------------------------------------------------
# Verifica se a bola chegou na posião x da barra 1 ou 2, e entra no label referente a colisão ocorrida.
PlayersCollision:
	movi r1, 620 # X da barra 2
	mov r2, r5   # X da bola
	addi r2, r2, 4
	bge r2, r1, verificarBarra2
	movi r1, 10 # X da barra 1
	subi r2, r2, 8 # X da barra
	bge r1, r2, verificarBarra1
	ret

# Faz a conversão do valor obtido pelo potenciometro para o y da tela e assim retorna a colisão ou não
verificarBarra1:
	/*movia r13, PLAYER1
	ldwio r1, 0(r13)
	movi r14, 1
	addi r1, r1, 1
	movi r3, 4
	custom 0, r1, r1, r3
	movi r3, 6
	custom 2, r1, r1, r3
	addi r1, r1, 220 #7
	mov r2, r6*/
	bge r2, r18, tamanhoBarra1
	ret

# Faz a conversão do valor pego pelo potenciometro para o y da tela e assim retorna a colisão ou não
verificarBarra2:
	/*movia r13, PLAYER2
	movi r14, -1
	ldwio r1, 0(r13)
	addi r1, r1, 1 # Add 1 em r1: r1 = r1 + 1
	movi r3, 4
	custom 0, r1, r1, r3 # Divide r1 por 4: r1 = r1 / 4
	movi r3, 6
	custom 2, r1, r1, r3 # Multiplica r1 por 6: r1 = r1 * 6
	addi r1, r1, 372 #7*/
	mov r2, r6
	bge r2, r18, tamanhoBarra2
	ret

# Ao colidir com a barra, dependendo da posição entra em um hit diferente
tamanhoBarra1:
	addi r1, r1, 16
	bge r1, r2, _hit1
	addi r1, r1, 16
	bge r1, r2, _hit2
	addi r1, r1, 16
	bge r1, r2, _hit3
	addi r1, r1, 16
	bge r1, r2, _hit4
	addi r1, r1, 16
	bge r1, r2, _hit5
	ret

# Ao colidir com a barra, dependendo da posição entra em um hit diferente
tamanhoBarra2:
	addi r1, r1, 16
	bge r1, r2, hit1
	addi r1, r1, 16
	bge r1, r2, hit2
	addi r1, r1, 16
	bge r1, r2, hit3
	addi r1, r1, 16
	bge r1, r2, hit4
	addi r1, r1, 16
	bge r1, r2, hit5
	ret
# ------------------------------------------------------------------------

#HIT BARRA DIREITA
hit1:
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
#Ao realizar uma colisão em qualquer parte do wall
#entra em uma parte diferente
wallCollision:
	movi r1, 471
	mov r2, r6
	addi r2,r2,4
	bge r2, r1, changeDownWall
	movi r1, 625
	mov r2, r5
	addi r2, r2, 4
	bge r2, r1, changeRightWall
	movi r1, 8
	mov r2, r6
	subi r2, r2, 4
	bge r1, r2, changeDownWall
	movi r1, 8
	mov r2, r5
	subi r2, r2, 4
	bge r1, r2, changeLeftWall
	ret
#Ao ocorrer a colisão em uma das walls
#Adiciona um ponto para o jogador caso
#o mesmo nao tenha atingido 5 pontos.
#Ao atingir 5 é dada a vitoria
changeRightWall:
	addi r9, r9, 1
	movi r1, 9
	beq r1, r9, win1
	addi r3, r9, 48
	movi r1, 0x8a
	instr r1
	data r3
	movi r7, 3
	mov r8, r7
	br resetBall

changeLeftWall:
	addi r10, r10, 1
	movi r1, 9
	beq r1, r10, win2
	addi r3, r10, 48
	movi r1, 0xca
	instr r1
	data r3
	movi r7, 3
	mov r8, r7
	br resetBall

#Ao bater na wall de cima ou baixo
#retorna no mesmo angulo de entrada
changeDownWall:
	movi r1, -1
	custom 2, r8,r8,r1
	ret

# GAME OVER --------------------------------------------------------------
#espera o botao de start para começar o jogo novamente
gameOver:
	ldwio r2, 0(r11)
	beq r2, r0, gameOver
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
   stw ra, 8(sp)
   movi r15, UART
   ldwio r17, 0(r15)                 # read the RS232 UART Data register 
   andi r16, r17, 0x8000             # check if there is new data 
   bne r16, r0, RETURN_CHAR
   mov r17, r0                      # if no new data, return ‘\0’ 
RETURN_CHAR:
   andi r16, r17, 0x00ff             # the data is in the least significant byte 
   mov r17, r16                      # set r17 with the return value 
   ldwio ra, 8(sp)
   
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