.data
    .equ btn, 0x5010
    .equ led, 0x5000
    .equ uart, 0x5020 #Endereço base da UART RS232
.text

.global main

# envia uma instrução para o LCD
.macro instr db
	custom 0, r0, r0, \db
.endm
# envia um dado para o LCD
.macro data db
	movi r1, 1
	custom 0, r0, r1, \db
.endm

#delay 1s
delay_1s:      
   movia r9, 25000000
d1s:  
   subi  r9,r9, 1
   bne   r9, r0, d1s
   ret
#-----------------------------

# Sub-rotina para enviar um caracter para o RS232 UART.
    # r6 = endereço base RS232 UART
    # r2 = character to send
PUT_CHAR:
   #delay 200ms
	movia r9, 0xCB735               # Setando o DELAY 200ms
   add r8, zero, zero				# Zera o registrador r8, adiciona +1us
   d200:
   addi r8, r8, 1       	   		# adiciona um ao contador
   bne r8, r9, d200	            # continua chamando a label

   ldwio r11, 4(r6)                 # ler o registrador de controle da UART RS232
   andhi r11, r11, 0x00ff            # verifica o espaço de escrita
   beq r11, r0, END_PUT             # se não houver espaço, ignora o caractere 
   stwio r2, 0(r6)                 # envia o caractere 
   data r2
END_PUT:
    ret
#----------------------------------------------------------------

# Sub-rotina para ler um caractere da RS232 UART.
   # r6 = endereço base RS232 UART
   # Retorna o caractere em r2. Retorna "\ 0" se não houver novo caractere na fila RX FIFO.
GET_CHAR:
   ldwio r2, 0(r6)                 # read the RS232 UART Data register 
   andi r8, r2, 0x8000             # check if there is new data 
   bne r8, r0, RETURN_CHAR
   mov r2, r0                      # if no new data, return ‘\0’ 
RETURN_CHAR:
   andi r8, r2, 0x00ff             # the data is in the least significant byte 
   mov r2, r8                      # set r2 with the return value 

   #Exibe dado de retorno do ESP no Display
   addi r11, zero, 0x0D
   beq r2, r11, FIM_CHAR
   addi r11, zero, 0x0A
   beq r2, r11, FIM_CHAR
 	data r2
FIM_CHAR:
   bne r2, zero, GET_CHAR          # Verifica se r2 é diferente de 0, caso seja ainda existem dados para ser lidos na uart
   ret
#----------------------------------------------------------------


#Inicializa o LCD
main:

    movia r3, btn
    movia r4, led
    movia r6, uart
    addi r5, r0, 1

# Apaga os LED's
    ldbio r7, 0(r3)
	stwio r7, 0(r4)
#-----------------------------------------

# Rotina de inicialização do display LCD
	movi r2, 0x38
	instr r2
	movi r2, 0x0c
	instr r2
	movi r2, 0x6
	instr r2
	movi r2, 0x1
	instr r2
#----------------------------------------------------------------------

# Rotina de inicialização do ESP-01 8266

# Rotina para desativar o eco do ESP: ATE0
disable_echo:
   addi r2, zero, 0x41 # A
   call PUT_CHAR
   addi r2, zero, 0x54 # T
   call PUT_CHAR
   addi r2, zero, 0x45 # E
   call PUT_CHAR
   addi r2, zero, 0x30 # 0
   call PUT_CHAR
   addi r2, zero, 0x0D # /r
   call PUT_CHAR
   addi r2, zero, 0x0A # /n
   call PUT_CHAR
   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2
   
# Rotina para setar o modo wifi como 1: AT+CWMODE_CUR=1
set_wifi_mode:
   addi r2, zero, 0x41 # A 
   call PUT_CHAR
   addi r2, zero, 0x54 # T 
   call PUT_CHAR
   addi r2, zero, 0x2b # + 
   call PUT_CHAR
   addi r2, zero, 0x43 # C 
   call PUT_CHAR
   addi r2, zero, 0x57 # w 
   call PUT_CHAR
   addi r2, zero, 0x4d # M 
   call PUT_CHAR
   addi r2, zero, 0x4f # O 
   call PUT_CHAR
   addi r2, zero, 0x44 # D 
   call PUT_CHAR
   addi r2, zero, 0x45 # E 
   call PUT_CHAR
   addi r2, zero, 0x5f # _ 
   call PUT_CHAR
   addi r2, zero, 0x43 # C 
   call PUT_CHAR
   addi r2, zero, 0x55 # U 
   call PUT_CHAR
   addi r2, zero, 0x52 # R 
   call PUT_CHAR
   addi r2, zero, 0x3d # = 
   call PUT_CHAR
   addi r2, zero, 0x31 # 1 
   call PUT_CHAR
   addi r2, zero, 0x0D # /r 
   call PUT_CHAR
   addi r2, zero, 0x0A # /n 
   call PUT_CHAR
   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR   #Ler o retorno do ESP

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2

# Rotina de conexão ao wifi: AT+CWJAP_CUR="WLessLEDS","HelloWorldMP31"
wifi_conect:
   addi r2, zero, 0x41 # A 
   call PUT_CHAR
   addi r2, zero, 0x54 # T 
   call PUT_CHAR
   addi r2, zero, 0x2b # + 
   call PUT_CHAR
   addi r2, zero, 0x43 # C 
   call PUT_CHAR
   addi r2, zero, 0x57 # w 
   call PUT_CHAR
   addi r2, zero, 0x4a # J 
   call PUT_CHAR
   addi r2, zero, 0x41 # A 
   call PUT_CHAR
   addi r2, zero, 0x50 # P 
   call PUT_CHAR
   addi r2, zero, 0x5f # _ 
   call PUT_CHAR
   addi r2, zero, 0x43 # C 
   call PUT_CHAR
   addi r2, zero, 0x55 # U 
   call PUT_CHAR
   addi r2, zero, 0x52 # R 
   call PUT_CHAR
   addi r2, zero, 0x3d # = 
   call PUT_CHAR
   #-------- SSID -------- 
   addi r2, zero, 0x22 # " 
   call PUT_CHAR
   addi r2, zero, 0x57 # W 
   call PUT_CHAR
   addi r2, zero, 0x4c # L 
   call PUT_CHAR
   addi r2, zero, 0x65 # e 
   call PUT_CHAR
   addi r2, zero, 0x73 # s 
   call PUT_CHAR
   addi r2, zero, 0x73 # s 
   call PUT_CHAR
   addi r2, zero, 0x4c # L 
   call PUT_CHAR
   addi r2, zero, 0x45 # E 
   call PUT_CHAR
   addi r2, zero, 0x44 # D 
   call PUT_CHAR
   addi r2, zero, 0x53 # S 
   call PUT_CHAR
   addi r2, zero, 0x22 # " 
   call PUT_CHAR
   #----------------------
   addi r2, zero, 0x2c # , 
   call PUT_CHAR
   #------- SENHA --------
   addi r2, zero, 0x22 # " 
   call PUT_CHAR
   addi r2, zero, 0x48 # H 
   call PUT_CHAR
   addi r2, zero, 0x65 # e 
   call PUT_CHAR
   addi r2, zero, 0x6c # l 
   call PUT_CHAR
   addi r2, zero, 0x6c # l 
   call PUT_CHAR
   addi r2, zero, 0x6f # o 
   call PUT_CHAR
   addi r2, zero, 0x57 # W 
   call PUT_CHAR
   addi r2, zero, 0x6f # o 
   call PUT_CHAR
   addi r2, zero, 0x72 # r 
   call PUT_CHAR
   addi r2, zero, 0x6c # l 
   call PUT_CHAR
   addi r2, zero, 0x64 # d 
   call PUT_CHAR
   addi r2, zero, 0x4d # M 
   call PUT_CHAR
   addi r2, zero, 0x50 # P 
   call PUT_CHAR
   addi r2, zero, 0x33 # 3 
   call PUT_CHAR
   addi r2, zero, 0x31 # 1 
   call PUT_CHAR
   addi r2, zero, 0x22 # " 
   call PUT_CHAR
   #----------------------
   addi r2, zero, 0x0D # /r 
   call PUT_CHAR
   addi r2, zero, 0x0A # /n 
   call PUT_CHAR
    
   movi r2, 0x1 # Limpar display
   instr r2
   call delay_1s
   call GET_CHAR
   call delay_1s

   movi r2, 0x1 # Limpar display
   instr r2


#----------------------------------------
# LOOP PRINCIPAL
loop:
    # Nas linhas abaixo é verificado em qual estado está o programa e é mostrado na tela a mensagem corespondente
    addi r8, r0, 1
    bne r5, r8, retmenu1 
    call menu1
retmenu1:
    addi r8, r0, 2
    bne r5, r8, retmenu2 
    call menu2
retmenu2:
    addi r8, r0, 3
    bne r5, r8, retmenu3
    call menu3
retmenu3:
    addi r8, r0, 4
    bne r5, r8, retmenu4
    call menu4
retmenu4:
    addi r8, r0, 5
    bne r5, r8, retmenu5
    call menu5
retmenu5:

    # verifica se deve salvar em r13 o valor do estado atual e zerar o registrador de controle de estado
    beq r5, zero, retverifica
    add r13, r0, r5 
    addi r5, r0, 0 
retverifica:
    # lê botões e faz anti-debouncing (metodo escolhido: travar em loop até sinal voltar para nivel normal, usando outro registrador como controle)
    ldbio r7, 0(r3) 
antibouncing:
    ldbio r2, 0(r3)
    addi r8, r0, 15
    bne r2, r8, antibouncing
    
    #verifica botão DOWN

    addi r8, r0, 7
    bne r8, r7, notbtndown 
    addi r9, r13, 1
    addi r8, r0, 6
    bne r9, r8, notbottommenu
    addi r9, r0, 1
notbottommenu:
    add r5, r0, r9
notbtndown:

    #verifica botão UP

    addi r8, r0, 11
    bne r8, r7, notbtnup 
    subi r9, r13, 1
    addi r8, r0, 0
    bne r9, r8, nottopmenu
    addi r9, r0, 5
nottopmenu:
    add r5, r0, r9
notbtnup:

    #verifica botão SELECT

    addi r8, r0, 13
    bne r8, r7, notbtnselect 
    addi r8, r0, 1
    bne r9, r8, notm1
    call mensagem1
notm1:
    addi r8, r0, 2
    bne r9, r8, notm2
    call mensagem2
notm2:
    addi r8, r0, 3
    bne r9, r8, notm3
    call mensagem3
notm3:
    addi r8, r0, 4
    bne r9, r8, notm4
    call mensagem4
notm4:
    addi r8, r0, 5
    bne r9, r8, notm5
    call mensagem5
notm5:

notbtnselect:

    br loop
#----------------------------------------
# Menu 1 até 5

menu1:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x7e #[SETA]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x31 #1
 	data r2

    movi r2, 0xc0 # Ir para linha 2
	instr r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x32 #2
 	data r2
    ret
menu2:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x31 #1
 	data r2

    movi r2, 0xc0 # Ir para linha 2
	instr r2
    movi r2, 0x7e #[SETA]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x32 #2
 	data r2
    ret
menu3:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x7e #[SETA]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x33 #3
 	data r2

    movi r2, 0xc0 # Ir para linha 2
	instr r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x34 #4
 	data r2
    ret
menu4:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x33 #3
 	data r2

    movi r2, 0xc0 # Ir para linha 2
	instr r2
    movi r2, 0x7e #[SETA]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x34 #4
 	data r2
    ret
menu5:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x7e #[SETA]
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x50 #P
 	data r2
    movi r2, 0x43 #C
 	data r2
    movi r2, 0x41 #A
 	data r2
    movi r2, 0x4f #O
 	data r2
	movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x35 #5
 	data r2
    ret
#-----------------------------------------
# Escrever Mensagens no LCD

mensagem1:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x45 #E
 	data r2
    movi r2, 0x44 #D
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x31 #1
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
    movi r2, 0x4e #O
 	data r2
    addi r8, r0, 7
    stwio r8, 0(r4)
    addi r13, zero, 1
   br conect_server
   whaitreturn1:    
    ldbio r7, 0(r3) 
    ldbio r10, 0(r3)
    addi r8, r0, 15
    bne r10, r8, whaitreturn1
    addi r8, r0, 14
    bne r7, r8, whaitreturn1
    addi r5, r0, 1
    addi r8, r0, 15
    stwio r8, 0(r4)
    ret
mensagem2:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x45 #E
 	data r2
    movi r2, 0x44 #D
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x32 #2
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
    movi r2, 0x4e #O
 	data r2
    addi r8, r0, 0x31
    stwio r8, 0(r4)
    addi r13, r0, 0x32
   br conect_server
    whaitreturn2:    
    ldbio r7, 0(r3) 
    ldbio r10, 0(r3)
    addi r8, r0, 15
    bne r10, r8, whaitreturn2
    addi r8, r0, 14
    bne r7, r8, whaitreturn2
    addi r5, r0, 2
    addi r8, r0, 15
    stwio r8, 0(r4)
    ret
mensagem3:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x45 #E
 	data r2
    movi r2, 0x44 #D
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x33 #3
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
    movi r2, 0x4e #O
 	data r2
    addi r8, r0, 13
    stwio r8, 0(r4)
    addi r13, r0, 0x33
   br conect_server
    whaitreturn3:    
    ldbio r7, 0(r3) 
    ldbio r10, 0(r3)
    addi r8, r0, 15
    bne r10, r8, whaitreturn3
    addi r8, r0, 14
    bne r7, r8, whaitreturn3
    addi r5, r0, 3
    addi r8, r0, 15
    stwio r8, 0(r4)
    ret
mensagem4:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x45 #E
 	data r2
    movi r2, 0x44 #D
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x34 #4
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
    movi r2, 0x4e #O
 	data r2
    addi r8, r0, 14
    stwio r8, 0(r4)
    addi r13, r0, 0x34
   br conect_server
    whaitreturn4:    
    ldbio r7, 0(r3) 
    ldbio r10, 0(r3)
    addi r8, r0, 15
    bne r10, r8, whaitreturn4
    addi r8, r0, 14
    bne r7, r8, whaitreturn4
    addi r5, r0, 4
    addi r8, r0, 15
    stwio r8, 0(r4)
    ret
mensagem5:
    movi r2, 0x1 # Limpar display
	instr r2
    movi r1, 0x41 #A
 	data r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4c #L
 	data r2
    movi r2, 0x45 #E
 	data r2
    movi r2, 0x44 #D
 	data r2
    movi r2, 0x53 #S
 	data r2
    movi r2, 0x20 #[SPACE]
 	data r2
    movi r2, 0x4f #O
 	data r2
    movi r2, 0x4e #O
 	data r2
    stwio r0, 0(r4)
    addi r13, r0, 0x35
   br conect_server
    whaitreturn5:    
    ldbio r7, 0(r3) 
    ldbio r10, 0(r3)
    addi r8, r0, 15
    bne r10, r8, whaitreturn5
    addi r8, r0, 14
    bne r7, r8, whaitreturn5
    addi r5, r0, 5
    addi r8, r0, 15
    stwio r8, 0(r4)
    ret

#---------------------------------------------------------------

#----------------------------------------

# Rotina para conectar no servidor TCP: AT+CIPSTART="TCP","192.168.1.201", "1883"
conect_server:
    addi r2, zero, 0x41 # A 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x2b # + 
    call PUT_CHAR
    addi r2, zero, 0x43 # C 
    call PUT_CHAR
    addi r2, zero, 0x49 # I 
    call PUT_CHAR
    addi r2, zero, 0x50 # P 
    call PUT_CHAR
    addi r2, zero, 0x53 # S 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x41 # A 
    call PUT_CHAR
    addi r2, zero, 0x52 # R 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x3d # = 
    call PUT_CHAR
    addi r2, zero, 0x22 # " 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x43 # C 
    call PUT_CHAR
    addi r2, zero, 0x50 # P 
    call PUT_CHAR
    addi r2, zero, 0x22 # " 
    call PUT_CHAR
    addi r2, zero, 0x2c # , 
    call PUT_CHAR
    addi r2, zero, 0x22 # " 
    call PUT_CHAR
    addi r2, zero, 0x31 # 1 
    call PUT_CHAR
    addi r2, zero, 0x39 # 9 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x2e # . 
    call PUT_CHAR
    addi r2, zero, 0x31 # 1 
    call PUT_CHAR
    addi r2, zero, 0x36 # 6 
    call PUT_CHAR
    addi r2, zero, 0x38 # 8 
    call PUT_CHAR
    addi r2, zero, 0x2e # . 
    call PUT_CHAR
    addi r2, zero, 0x31 # 1 
    call PUT_CHAR
    addi r2, zero, 0x2e # . 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x30 # 0 
    call PUT_CHAR
    addi r2, zero, 0x31 # 1 
    call PUT_CHAR
    addi r2, zero, 0x22 # " 
    call PUT_CHAR
    addi r2, zero, 0x2c # , 
    call PUT_CHAR
    addi r2, zero, 0x31 # 1 
    call PUT_CHAR
    addi r2, zero, 0x38 # 8 
    call PUT_CHAR
    addi r2, zero, 0x38 # 8 
    call PUT_CHAR
    addi r2, zero, 0x33 # 3 
    call PUT_CHAR
    #---------------
    addi r2, zero, 0x0D # /r 
    call PUT_CHAR
    addi r2, zero, 0x0A # /n 
    call PUT_CHAR

   movi r2, 0x1 # Limpar display
   instr r2
   call delay_1s
   call GET_CHAR
   call delay_1s

   
   movi r2, 0x1 # Limpar display
   instr r2

#Rotina para enviar o send_x de payload: AT+CIPSENDEX=22
send_x_payload:
    addi r2, zero, 0x41 # A 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x2b # + 
    call PUT_CHAR
    addi r2, zero, 0x43 # C 
    call PUT_CHAR
    addi r2, zero, 0x49 # I 
    call PUT_CHAR
    addi r2, zero, 0x50 # P 
    call PUT_CHAR
    addi r2, zero, 0x53 # S 
    call PUT_CHAR
    addi r2, zero, 0x45 # E 
    call PUT_CHAR
    addi r2, zero, 0x4e # N 
    call PUT_CHAR
    addi r2, zero, 0x44 # D 
    call PUT_CHAR
    addi r2, zero, 0x45 # E 
    call PUT_CHAR
    addi r2, zero, 0x58 # X 
    call PUT_CHAR
    addi r2, zero, 0x3d # = 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x0D # /r 
    call PUT_CHAR
    addi r2, zero, 0x0A # /n 
    call PUT_CHAR

   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2

# Rotina de envio do payload: 0x10,0x14,0x00,0x04,0x4d,0x51,0x54,0x54,0x04,0x02,0x00,0x3c,0x00,0x08,0x45,0x53,0x50,0x2d,0x38,0x32,0x36,0x36
payload:
    addi r2, zero, 0x10
    call PUT_CHAR
    addi r2, zero, 0x14
    call PUT_CHAR
    addi r2, zero, 0x00
    call PUT_CHAR
    addi r2, zero, 0x04
    call PUT_CHAR
    addi r2, zero, 0x4d # M
    call PUT_CHAR
    addi r2, zero, 0x51 # Q
    call PUT_CHAR
    addi r2, zero, 0x54 # T
    call PUT_CHAR
    addi r2, zero, 0x54 # T
    call PUT_CHAR
    addi r2, zero, 0x04
    call PUT_CHAR
    addi r2, zero, 0x02
    call PUT_CHAR
    addi r2, zero, 0x00
    call PUT_CHAR
    addi r2, zero, 0x3c # <
    call PUT_CHAR
    addi r2, zero, 0x00
    call PUT_CHAR
    addi r2, zero, 0x08 
    call PUT_CHAR
    addi r2, zero, 0x45 # E
    call PUT_CHAR
    addi r2, zero, 0x53 # S
    call PUT_CHAR
    addi r2, zero, 0x50 # P
    call PUT_CHAR
    addi r2, zero, 0x2d # -
    call PUT_CHAR
    addi r2, zero, 0x38 # 8
    call PUT_CHAR
    addi r2, zero, 0x32 # 2
    call PUT_CHAR
    addi r2, zero, 0x36 # 6
    call PUT_CHAR
    addi r2, zero, 0x36 # 6
    call PUT_CHAR
    addi r2, zero, 0x0D # /r 
    call PUT_CHAR
    addi r2, zero, 0x0A # /n 
    call PUT_CHAR

   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2

send_x:
    addi r2, zero, 0x41 # A 
    call PUT_CHAR
    addi r2, zero, 0x54 # T 
    call PUT_CHAR
    addi r2, zero, 0x2b # + 
    call PUT_CHAR
    addi r2, zero, 0x43 # C 
    call PUT_CHAR
    addi r2, zero, 0x49 # I 
    call PUT_CHAR
    addi r2, zero, 0x50 # P 
    call PUT_CHAR
    addi r2, zero, 0x53 # S 
    call PUT_CHAR
    addi r2, zero, 0x45 # E 
    call PUT_CHAR
    addi r2, zero, 0x4e # N 
    call PUT_CHAR
    addi r2, zero, 0x44 # D 
    call PUT_CHAR
    addi r2, zero, 0x45 # E 
    call PUT_CHAR
    addi r2, zero, 0x58 # X 
    call PUT_CHAR
    addi r2, zero, 0x3d # = 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x32 # 2 
    call PUT_CHAR
    addi r2, zero, 0x0D # /r 
    call PUT_CHAR
    addi r2, zero, 0x0A # /n 
    call PUT_CHAR

   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2

envia_msg:
    addi r2, zero, 0x30 #0
    call PUT_CHAR
    addi r2, zero, 0x13
    call PUT_CHAR
    addi r2, zero, 0x00 
    call PUT_CHAR
    addi r2, zero, 0x07
    call PUT_CHAR
    addi r2, zero, 0x53 # S
    call PUT_CHAR
    addi r2, zero, 0x44 # D
    call PUT_CHAR
    addi r2, zero, 0x54 # T
    call PUT_CHAR
    addi r2, zero, 0x6f # o
    call PUT_CHAR
    addi r2, zero, 0x70 # p
    call PUT_CHAR
    addi r2, zero, 0x69 # i
    call PUT_CHAR
    addi r2, zero, 0x63 # c
    call PUT_CHAR
    addi r2, zero, 0x00
    call PUT_CHAR
    addi r2, zero, 0x4c # L 
    call PUT_CHAR
    addi r2, zero, 0x45 # E 
    call PUT_CHAR
    addi r2, zero, 0x44 # D 
    call PUT_CHAR
    addi r2, zero, 0x20 # [SPACE] 
    call PUT_CHAR
    add r2, zero, r13 # 1
    call PUT_CHAR
    addi r2, zero, 0x20 # [SPACE] 
    call PUT_CHAR
    addi r2, zero, 0x50 # P 
    call PUT_CHAR
    addi r2, zero, 0x30 # 0 
    call PUT_CHAR
    addi r2, zero, 0x33 # 3 
    call PUT_CHAR
    addi r2, zero, 0x0D # /r 
    call PUT_CHAR
    addi r2, zero, 0x0A # /n 
    call PUT_CHAR

   movi r2, 0x1 # Limpar display
   instr r2
   call GET_CHAR

   call delay_1s
   movi r2, 0x1 # Limpar display
   instr r2
   addi r5, r0, 1
   br loop

#-----------------------------------------
br end 

end:
	br end
.end