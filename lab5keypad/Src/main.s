# main.s
# Trevor Barnes
# CE2801-031
# Lab 3: Keypad API
# Description: The driver for Lab 5 

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main


main:

	bl lcdInit
    bl KeyInit

    # Location of cursor (1-32)
    mov r2, #1
    # Address of char to print
    ldr r1, =charToPrint
    mov r0, #0
	strb r0, [r1, #8]
mainLoop:

    bl KeyGetChar
    # Store char in memory
    strb r0, [r1]
	mov r0, r1
    bl lcdPrintString
    add r2, #1
    cmp r2, #17
    bne 1f

    mov r0, #0
    mov r3, r1
    mov r1, #1
    bl lcdSetPosition
    mov r1, r3
1:
    cmp r2, #33
    bne 2f
    bl lcdClear
    bl lcdHome
    mov r2, #1
2:
    b mainLoop
end:
    b end

.section .data
charToPrint:
    .byte 0
