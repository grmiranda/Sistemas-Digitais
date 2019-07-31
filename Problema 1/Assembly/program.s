.global main

main:
    addi r4, zero, 0x5020
    br loop_send
    
loop_send:
    /*r7 é usado como reg de controle */

    /* Send character A */
    addi r9, zero, 0
    addi r3, zero, 0x41 /* A */
    beq r7, r9, PUT_CHAR

    /* Send character T */
    addi r9, zero, 1
    addi r3, zero, 0x54 /* T */
    beq r7, r9, PUT_CHAR

    /* Send character /r */
    addi r9, zero, 2
    addi r3, zero, 0x0D /* /r */
    beq r7, r9, PUT_CHAR

    /* Send character /n */
    addi r9, zero, 3
    addi r3, zero, 0x0A /* /n */
    beq r7, r9, PUT_CHAR

    /* Branch para ler os dados de retorno do esp */
    addi r9, zero, 4
    beq r7, r9, GET_CHAR

    /* END */
    addi r9, zero, 5
    beq r7, r9, end

/********************************************************************************
* Subroutine to send a character to the RS232 UART.
* r4 = RS232 UART base address
* r3 = character to send
********************************************************************************/
PUT_CHAR:
    /* save any modified registers */
    subi sp, sp, 4 /* reserve space on the stack */
    stw r6, 0(sp) /* save register */
    ldwio r6, 4(r4) /* read the RS232 UART Control register */
    andhi r6, r6, 0x00ff /* check for write space */
    beq r6, r0, END_PUT /* if no space, ignore the character */
    stwio r3, 0(r4) /* send the character */
    
    addi r7, r7, 1
END_PUT:
    /* restore registers */
    ldw r6, 0(sp)
    addi sp, sp, 4
    br main

GET_CHAR:
    /* save any modified registers */
    subi sp, sp, 8 /* reserve space on the stack */
    stw r5, 0(sp) /* save register */
    ldwio r2, 0(r4) /* read the RS232 UART Data register */
    andi r5, r2, 0x8000 /* check if there is new data */
    bne r5, r0, RETURN_CHAR
    mov r2, r0 /* if no new data, return ‘\0’ */
    
    addi r7, zero, 5 /*Seta o valor do reg de controle como 5 p/ finalizar*/
RETURN_CHAR:
    andi r5, r2, 0x00ff /* the data is in the least significant byte */
    mov r2, r5 /* set r2 with the return value */
    /* restore registers */
    ldw r5, 0(sp)
    addi sp, sp, 8
   br main

end:
    br end

/*Delayyyyyyyyyyyyyyyyyyyyyyyyyyyy */
delay:      movia r2, 25000000
wasteTime:  subi  r2,r2, 1
            bne   r2, r0, wasteTime
            br loop_send
            ret