# loopback
# -- Havallon & Crystal
#         22/11
    
.equ UART0RX, 0x3000
.equ UART0TX, 0x3004
.equ RxReady, 0x3008
.equ LED, 0x3020
.global main

main:
	movia r1, UART0RX # r1 como ponteiro para RxData do UART0
	movia r2, RxReady # r2 como ponteiro para flag RxReady
	movia r3, UART0TX # r3 como ponteiro para TxData do UART0
	movia r5, LED
loopback:
	ldw r4, 0(r2)
	andi r4, r4, 128
	beq r4, r0, loopback
	ldw r4, 0(r1)
	stw r4, 0 (r3)
	stw r4, 0(r5)
	br loopback