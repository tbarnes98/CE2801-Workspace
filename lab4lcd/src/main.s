# main.s
# Trevor Barnes
# CE2801-031
# Lab 3: LCD API
# Description: The driver for Lab 4. Displays the ASCII
#              values from the previous lab.

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main


main:
    bl lcdInit

mainLoop:

    bl lcdClear
    mov r0, #5
    bl countDown

    ldr r0, =msg
    bl lcdPrintString


    mov r0, #5
    bl countDown
    b mainLoop

end:
    b end

# r0 - value to be counted down from (0-9999)
countDown:
    push {r0,r1,lr}
loop:
    # Print number
    bl lcdPrintNum
    mov r1, r0
    mov r0, #1
    # Save current value before delay subroutine
    bl lcdHome
    mov r0, #1000
    bl delay_ms
    mov r0, r1
    cmp r0, #0
    beq done
    sub r0, r0, #1

    b loop
done:
    pop {r0,r1,pc}




.section .rodata
msg:
    .asciz "Hello World!"
