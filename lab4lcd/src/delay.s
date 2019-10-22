# delay.s
# Trevor Barnes
# CE2801-031
# Description: A file for handling delay routines

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global delay_ms
# A subroutine to create a delay of a certain number of milliseconds
# Input: 
#       r0: Length of delay (ms)
delay_ms:

    push {r1,r2,r3,lr}
    mov r3,r0
ms_delay:
	# 250 iterations = 1/16 of a millisecond
    mov r2, #0x10
# Loop 16 times
1:
	# 250
	mov r1, #0xFA
# Loop 250 times
2:
    sub r1, #1
    cmp r1, #0
    bne 2b

    sub r2, #1
    cmp r2, #0
    bne 1b

	sub r0, #1
	cmp r0, #0
    bne ms_delay

    mov r0,r3
    pop {r1,r2,r3,pc}

.global lcd_delay
# about r1 mircoseonds
lcd_delay:
	# stack
	push {lr}

	lsl r1, r1, #3

1:
	sub r1, r1, #1
    cmp r1, #0
	bne 1b

	# return
	pop {pc}


