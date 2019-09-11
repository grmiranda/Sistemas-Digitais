.equ UART0RX, 0x3000 # Endereço da RxData do UART0 na memoria
.equ flagUART0, 0x3008 # Endereço de memoria para aonde as flags RxReady e TxReady estão mapeadas
.equ UART0TX, 0x3004 # Endereço da TxData do UART0 na memoria
.equ LED, 0x3020 # Endereço dos leds

# Inserindo dado na pilha
.macro push reg
	subi sp, sp, 4
	stw \reg, 0(sp)
.endm

# Recuperando dado da pilha
.macro pop reg
	ldw \reg, 0(sp)
	addi sp, sp, 4
.endm

.data
vetor: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text

.global main

main:
    mov r1, sp
comain:
    call limpar
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
    movia r5, LED
    stw r0, 0(r5)
    mov sp, r1
waiting:
	# Verificando se há algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting
	ldw r4, 0(r2) # Lendo byte recebido
switch:
    movi r2, 49
    beq r4, r2, ano
    movi r2, 50
    beq r4, r2, bubble
    movi r2, 51
    beq r4, r2, fat
    movi r2, 52
    beq r4, r2, fib
    movi r2, 53
    beq r4, r2, primos
    br comain

ano:
    stw r4, 0(r5)
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
	movi r9, 10

waiting_ano:
	# Verificando se h� algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting_ano
	ldw r4, 0(r2) # Lendo byte recebido

is_enter_ano:
	cmpeqi r5, r4, 13 # Compara a entrada com o 13 (Valor do Enter pela tabela ASCII)
	beq r5, r0, is_not_enter_ano
	br inicio_ano
	
is_not_enter_ano:
	subi r4, r4, 48
	custom 0, r6, r6, r9
	add r6, r6, r4
	br waiting_ano

# USO DOS REGISTRADORES PARA O CALCULO DO ANO BISSEXTO
# r2 valor a ser calculado
# r3 auxiliares para a divisao. Assumindo ao decorrer do algoritmo 4, 100 e 400
# r4 auxiliar para o resto da divisao
# r6 resultado final

inicio_ano:
	mov r2, r6
	movi r3, 4
	custom 2, r4, r2, r3
	beq r4, r0, by4 #verificando se o numero � divisivel por 4
	br nao
by4:
	movi r3, 100
	custom 2, r4, r2, r3
	beq r4, r0, by100 #verificando se o numero � divisivel por 100
	movi r6, 1
	br sendinig_ano # Enviando o dado para UART
	
by100:
	movi r3, 400
	custom 2, r4, r2, r3
	beq r4, r0, by400 #verificando se o numero � divisivel por 400
	br nao
by400:
	movi r6, 1
	br sendinig_ano # Enviando o dado para UART
	
nao:
	movi r6, 0
	
# USO DOS REGISTRADORES PARA SAIDA DE DADOS
# r4 valor lido da flag TxReady
# r7 ponteiro para UART0TX
# r9 auxiliar para dividir por 10
# r10 inteiro a ser transmitido pela serial
# r11 auxiliar para enviar os caracter em ASCII
# r12 valor inicial de sp
# r13 auxilar para flag de compara�ao

sendinig_ano:
	movia r7, UART0TX # r7 como ponteiro para TxData do UART0
	movi r9, 10
	mov r10, r6 # movendo o resultado da verifica��o para r10
	mov r12, sp
loop_ano: 
	bge r10, r9, if_ano # While (r10 >= r9)
	push r10
	br send_ano

if_ano:	#Salvando o resto da divas�o por 10 na pilha
	custom 1, r11, r10, r9
	custom 0, r11, r11, r9
	sub r11, r10, r11
	push r11
	custom 1, r10, r10, r9 # r10 = r10/r9
	br loop_ano
	
send_ano: # Enviando os dados salvos na pilha
	pop r10
	addi r10, r10, 48 # Transformando em ASCII
	stw r10, 0(r7)
	cmpeq r13, sp, r12
	beq r13, r0, send_ano
	br end

# r2 ponteiro para UART0RX
# r3 ponteiro para flag RxReady
# r4 dado recebido na UART0
# r5 flag para saber se o enter foi pressionado
# r6 resultado do inteiro final obtido pela serial
# r7 tamanho do vetor
# r8 auxilar para salvar vetor na memoria
# r9 flag para saber se o valor da serial é o tamanho do vetor
# r10 contador para preencher o vetor
# r12 constante 10
bubble:
    stw r4, 0(r5)
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
	movia r8, vetor
	movi r11, 20
	movi r12, 10
	mov r9, r0
waiting_input_bubble:
	# Verificando se há algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting_input_bubble
	ldw r4, 0(r2) # Lendo byte recebido

is_enter_bubble:
	cmpeqi r5, r4, 13 # Compara a entrada com o 10 (Valor do Enter pela tabela ASCII)
	beq r5, r0, is_not_enter_bubble
	beq r9, r0, tamanhoVetor_bubble
	subi r10, r10, 1
	stw r6, 0(r8)
	addi r8, r8, 4
	mov r6, r0
	beq r10, r0, inicio_bubble
	br waiting_input_bubble
	
tamanhoVetor_bubble:
	beq r6, r0, erro
    bgt r6, r11, erro
	movi r9, 1
	mov r7, r6
	mov r10, r6
	mov r6, r0
	br waiting_input_bubble
	
is_not_enter_bubble:
	subi r4, r4, 48
	custom 0, r6, r6, r12
	add r6, r6, r4
	br waiting_input_bubble

#USO DOS REGISTRADORES PARA O ALGORITMO DE BUBBLESORT
# r2 contador i
# r3 contador j
# r4 auxilar para troca de posicao no vetor
# r5 inicio_bubble do vetor
# r6 tamanho do vetor
# r7 posicao atual do vetor
# r8 tamanho do vetor - 1
# r9 = vetor[j]
# r10 = vetor[j+1]

inicio_bubble:
	movi r15, 1
	movi r16, 1
	mov r6, r7 #r6 = n
	movia r5, vetor #r5 = &vetor	
	mov r7, r5 # r7 = r5
	mov r2, r0 
	mov r3, r0
	addi r2, r2, 1
	subi r8, r6, 1 # r8 = n-1
	
for1_bubble:
	beq r16, r15, mid_for_bubble # if (r16 = r15)
	br sending_bubble #else
	
mid_for_bubble:
	mov r15, r0
for2_bubble:
	
	bge r3, r8, end_for2_bubble # if (r3 >= r8)
	#else
	ldw r9, 0(r7)  #r9 = vetor[j]
	ldw r10, 4(r7) #10 = vetor[j+1]
	
	bge r10, r9, true_bubble # if (r10 >= r9) 
	#else
	mov r4, r9 # aux = vetor[j]
	stw r10, 0(r7) #vetor[j] = vetor[j + 1]
	stw r4, 4(r7)  #vetor[j+1] = aux
	movi r15,1

true_bubble: 
	addi r7, r7, 4 # pecorre o vetor
	addi r3, r3, 1 #j++
	br for2_bubble

end_for2_bubble:
	addi r2, r2, 1 #i++
	mov r7, r5 #resetar a posicao inicial do vetor
	mov r3, r0 # j = 0
	br for1_bubble

# USO DOS REGISTRADORES PARA SAIDA DE DADOS
# r7 ponteiro para UART0TX
# r9 auxiliar para dividir por 10
# r10 inteiro a ser transmitido pela serial
# r11 auxiliar para enviar os caracter em ASCII
# r12 valor inicial de sp
# r13 auxilar para flag de comparaçao
# r14 na flag

sending_bubble:
	movia r7, UART0TX # r7 como ponteiro para TxData do UART0
	movi r9, 10
	mov r12, sp
	mov r2, r0
	movia r14, flagUART0
while_bubble:
	beq r2, r6, end
	ldw r10, 0(r5) # movendo o resultado da verificação para r10
loop_bubble: 
	bge r10, r9, if_bubble # while_bubble (r10 >= r9)
	push r10
	br send_bubble

if_bubble:	#Salvando o resto da divasão por 10 na pilha
	custom 1, r11, r10, r9
	custom 0, r11, r11, r9
	sub r11, r10, r11
	push r11
	custom 1, r10, r10, r9 # r10 = r10/r9
	br loop_bubble
	
send_bubble: # Enviando os dados salvos na pilha
	ldw r15, 0(r14)
	andi r15, r15, 64
	beq r15, r0, send_bubble
	pop r10
	addi r10, r10, 48 # Transformando em ASCII
	stw r10, 0(r7)
	cmpeq r13, sp, r12
	beq r13, r0, send_bubble
	call send_enter_bubble
	addi r5, r5, 4
	addi r2, r2, 1
	br while_bubble
	
send_enter_bubble:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_enter_bubble
	stw r9, 0(r7)
send_return_bubble:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_return_bubble
	movi r16, 13
	stw r16, 0(r7)
	ret

fat:
	stw r4, 0(r5)
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
	movi r9, 10
	movi r10, 12
waiting_input_fat:
	# Verificando se h� algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting_input_fat
	ldw r4, 0(r2) # Lendo byte recebido

is_enter_fat:
	cmpeqi r5, r4, 13 # Compara a entrada com o 13 (Valor do Enter pela tabela ASCII)
	beq r5, r0, is_not_enter_fat
	bgt r6, r10, erro
	br inicio_fat
	
is_not_enter_fat:
	subi r4, r4, 48
	custom 0, r6, r6, r9
	add r6, r6, r4
	br waiting_input_fat

# USO DOS REGISTRADORES PARA O CALCULO DO FATORIAL
# r2 valor a ser calculado
# r3 constante 2
# r4 resultado do fatorial

inicio_fat:
	mov r2, r6
	movi r3, 2
	call fatorial_fat
	br sending_fat # Enviando o dado para UART
	
fatorial_fat:
	blt r2, r3, menor2_fat #Condi��o de parada
	
	#salvando os dados necessarios para a recurs�o
	push ra
	push r2
	subi r2, r2, 1 # r2--;
	call fatorial_fat # recurs�o
	
	#recuperando o dados ap�s o retorno da fun��o
	pop r2
	pop ra
	custom 0, r4, r2, r4 # r4 = r2 * fatorial(r2-1);
	ret


menor2_fat:
	movi r4, 1
	ret

# USO DOS REGISTRADORES PARA SAIDA DE DADOS
# r7 ponteiro para UART0TX
# r9 auxiliar para dividir por 10
# r10 inteiro a ser transmitido pela serial
# r11 auxiliar para enviar os caracter em ASCII
# r12 valor inicial de sp
# r13 auxilar para flag de compara�ao
# r14 flagTx
sending_fat:
	movia r7, UART0TX # r7 como ponteiro para TxData do UART0
	movi r9, 10
	mov r10, r4 # movendo o resultado da verifica��o para r10
	mov r12, sp
	movia r14, flagUART0
loop_fat: 
	bge r10, r9, if_fat # While (r10 >= r9)
	push r10
	br send_fat

if_fat:	#Salvando o resto da divas�o por 10 na pilha
	custom 1, r11, r10, r9
	custom 0, r11, r11, r9
	sub r11, r10, r11
	push r11
	custom 1, r10, r10, r9 # r10 = r10/r9
	br loop_fat
	
send_fat: # Enviando os dados salvos na pilha
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_fat
	pop r10
	addi r10, r10, 48 # Transformando em ASCII
	stw r10, 0(r7)
	cmpeq r13, sp, r12
	beq r13, r0, send_fat
	br end

fib:
	stw r4, 0(r5)
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
	movi r9, 10
	movi r10, 31
waiting_input_fib:
	# Verificando se h� algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting_input_fib
	ldw r4, 0(r2) # Lendo byte recebido

is_enter_fib:
	cmpeqi r5, r4, 13 # Compara a entrada com o 10 (Valor do Enter pela tabela ASCII)
	beq r5, r0, is_not_enter_fib
	bgt r6, r10, erro
	br inicio_fib
	
is_not_enter_fib:
	subi r4, r4, 48
	custom 0, r6, r6, r9
	add r6, r6, r4
	br waiting_input_fib

# USO DOS REGISTRADORES PARA FIBONACCI
# r2 quantidade da sequencia
# r8 contador i
# r3 Constante 1
# r4 Resultado fibonacci
# r5 Parametro de entrada do fibonacci
# r6 auxilar para calculo do fibonacci

inicio_fib:
	mov r8, r0
	addi r8, r8, 1
	mov r2, r6

while_fib:
	bge r2, r8, start_fib
	br end

start_fib:
	movi r3, 1
	mov r4, r0
	push r8
	call fibonacci_fib
	call sending_fib
	addi r8, r8, 1
	br while_fib
	
fibonacci_fib:
	pop r5
	bgt r5, r3, do
	add r4, r4, r5
	ret

do:
	push ra
	subi r6, r5, 1
	push r6
	subi r6, r6, 1
	push r6
	call fibonacci_fib
	call fibonacci_fib
	pop ra
	ret	
	
# USO DOS REGISTRADORES PARA SAIDA DE DADOS
# r7 ponteiro para UART0TX
# r9 auxiliar para dividir por 10
# r10 inteiro a ser transmitido pela serial
# r11 auxiliar para enviar os caracter em ASCII
# r12 valor inicial de sp
# r13 auxilar para flag de compara�ao
# r14 flagUART0
sending_fib:
	movia r7, UART0TX # r7 como ponteiro para TxData do UART0
	movi r9, 10
	mov r10, r4 # movendo o resultado da verifica��o para r10
	mov r12, sp
	movia r14, flagUART0
loop_fib: 
	bge r10, r9, if_fib # While (r10 >= r9)
	push r10
	br send_fib

if_fib:	#Salvando o resto da divas�o por 10 na pilha
	custom 1, r11, r10, r9
	custom 0, r11, r11, r9
	sub r11, r10, r11
	push r11
	custom 1, r10, r10, r9 # r10 = r10/r9
	br loop_fib
	
send_fib: # Enviando os dados salvos na pilha
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_fib

	pop r10
	addi r10, r10, 48 # Transformando em ASCII
	stw r10, 0(r7)
	cmpeq r13, sp, r12
	beq r13, r0, send_fib
	push ra
	call send_enter_fib
	pop ra
	ret
	
send_enter_fib:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_enter_fib
	stw r9, 0(r7)
send_return_fib:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_return_fib
	movi r16, 13
	stw r16, 0(r7)
	ret

primos:
	stw r4, 0(r5)
	movia r2, UART0RX # r2 como ponteiro para RxData do UART0
	movia r3, flagUART0 # r3 como ponteiro para flag RxReady
	movi r7, 2
	movi r9, 10

waiting_input_primos:
	# Verificando se h� algum dado para ser lido
	ldw r4, 0(r3)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, waiting_input_primos
	ldw r4, 0(r2) # Lendo byte recebido

is_enter_primos:
	cmpeqi r5, r4, 13 # Compara a entrada com o 10 (Valor do Enter pela tabela ASCII)
	beq r5, r0, is_not_enter_primos
	subi r7, r7, 1
	push r6
	mov r6, r0
	beq r7, r0, inicio_primos
	br waiting_input_primos
	
is_not_enter_primos:
	subi r4, r4, 48
	custom 0, r6, r6, r9
	add r6, r6, r4
	br waiting_input_primos

# USO DOS REGISTRADORES PARA CALCULO DOS NUMEROS PRIMOS
# r2 primeiro valor do intervalo
# r3 ultimo valor do intervalo
# r4 a diferen�a entre os intervalos
# r5 contador1
# r6 contador2
# r7 flag para detectar o numero primo
# r8 constante 1
inicio_primos:
	pop r3
	pop r2
	sub r4, r3, r2
	movi r5, 0
	movi r6, 2
	movi r7, 0
	movi r8, 1
		
loop1_primos:
	blt r4, r5, end
	cmpeqi r7, r2, 2
	call loop2_primos
	movi r6, 2
	addi r5, r5, 1
	beq r7, r8, sending_primos
	addi r2, r2, 1
	br loop1_primos
	
loop2_primos:
	bge r6, r2, endloop2_primos
	custom 2, r9, r2, r6
	beq r9, r0, else_primos
	movi r7, 1
	addi r6, r6, 1
	br loop2_primos
	
endloop2_primos:
	ret

else_primos:
	movi r7, 0
	ret

	
# USO DOS REGISTRADORES PARA SAIDA DE DADOS
# r7 ponteiro para UART0TX
# r9 auxiliar para dividir por 10
# r10 inteiro a ser transmitido pela serial
# r11 auxiliar para enviar os caracter em ASCII
# r12 valor inicial de sp
# r13 auxilar para flag de compara�ao
# r14 flag
sending_primos:
	movia r7, UART0TX # r7 como ponteiro para TxData do UART0
	movi r9, 10
	mov r10, r2 # movendo o resultado da verifica��o para r10
	mov r12, sp
	movia r14, flagUART0

loop_primos: 
	bge r10, r9, if_primos # While (r10 >= r9)
	push r10
	br send_primos

if_primos:	#Salvando o resto da divas�o por 10 na pilha
	custom 1, r11, r10, r9
	custom 0, r11, r11, r9
	sub r11, r10, r11
	push r11
	custom 1, r10, r10, r9 # r10 = r10/r9
	br loop_primos
	
send_primos: # Enviando os dados salvos na pilha
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_primos

	pop r10
	addi r10, r10, 48 # Transformando em ASCII
	stw r10, 0(r7)
	cmpeq r13, sp, r12
	beq r13, r0, send_primos
	call send_enter_primos
	addi r2, r2, 1
	br loop1_primos
	
send_enter_primos:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_enter_primos
	stw r9, 0(r7)
send_return_primos:
	ldw r15, 0(r14)
	andi r15, r15, 64 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r15, r0, send_return_primos
	movi r16, 13
	stw r16, 0(r7)
	ret

limpar:
    mov r2, r0
    mov r3, r0
    mov r4, r0
    mov r5, r0
    mov r6, r0
    mov r7, r0
    mov r8, r0
    mov r9, r0
    mov r10, r0
    mov r11, r0
    mov r12, r0
    mov r13, r0
    mov r14, r0
    mov r15, r0
    mov r16, r0
    ret

erro:
	movia r10, LED
	movi r11, 0xFF
	stw r11, 0(r10)
end:
	movia r2, flagUART0
    movia r3, UART0RX
end_2:
	ldw r4, 0(r2)
	andi r4, r4, 128 # a flag rxReady ta mapeada no 8 bit menos significativo 
	beq r4, r0, end_2
    ldw r4, 0(r3)
	br comain
	.end