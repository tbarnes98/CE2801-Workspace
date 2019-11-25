# keypad.s
# Trevor Barnes
# CE2801-031
# Description: Contains routines for the keypad component

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOCEN, 1<<2

    .equ GPIOC_BASE, 0x40020800 
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_IDR, 0x10
    .equ GPIO_PUPDR, 0x0C
    .equ GPIO_BSRR, 0x18

    # Row 1
	.equ k1,  0xEE
	.equ k2,  0xED
	.equ k3,  0xEB
	.equ k4,  0xE7

    # Row 2
	.equ k5,  0xDE
	.equ k6,  0xDD
	.equ k7,  0xDB
	.equ k8,  0xD7

    # Row 3
	.equ k9,  0xBE
	.equ k10, 0xBD
	.equ k11, 0xBB
	.equ k12, 0xB7

    # Row 4
    .equ k13, 0x7E
	.equ k14, 0x7D
	.equ k15, 0x7B
	.equ k16, 0x77

.global KeyInit
# Initialize the keypad GPIO port.  
# Depending on your scanning algorithm, 
# there may not be any work to do in this method
KeyInit:

    push {r0,r1,r2,lr}

    ldr r1, =RCC_BASE

    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOCEN
    str r2, [r1, #RCC_AHB1ENR]

    # Read current PUPDR state
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_PUPDR]

    # Modify and write rows and columns to be "Pull-Up"
    bfc r2, #0, #16
    ldr r0, =0x5555
    orr r2, r2, r0
    str r2, [r1, #GPIO_PUPDR]

    pop {r0,r1,r2,pc}

.global KeyGetKeyNoblock
# Returns in r0 a numeric code representing 
# the button on the keypad that was pressed (1 to 16),
# or 0 if no button is pressed
KeyGetKeyNoblock:

    push {r1,r2,lr}

    bl keypadScan

	mov r1, #0

	ubfx r2, r0, #4, #4

	cmp r2, #0xF
	beq 1f

    add r1, #1
    cmp r0, #k1
    beq 1f

    add r1, #1
    cmp r0, #k2
    beq 1f

    add r1, #1
    cmp r0, #k3
    beq 1f

    add r1, #1
    cmp r0, #k4
    beq 1f

    add r1, #1
    cmp r0, #k5
    beq 1f

    add r1, #1
    cmp r0, #k6
    beq 1f

    add r1, #1
    cmp r0, #k7
    beq 1f

    add r1, #1
    cmp r0, #k8
    beq 1f

    add r1, #1
    cmp r0, #k9
    beq 1f

    add r1, #1
    cmp r0, #k10
    beq 1f

    add r1, #1
    cmp r0, #k11
    beq 1f

    add r1, #1
    cmp r0, #k12
    beq 1f

    add r1, #1
    cmp r0, #k13
    beq 1f

    add r1, #1
    cmp r0, #k14
    beq 1f

    add r1, #1
    cmp r0, #k15
    beq 1f

    add r1, #1
    cmp r0, #k16
    beq 1f

1:
    mov r0, r1

    pop {r1,r2,pc}


.global KeyGetKey
# Same as KeyGetkeyNoblock, but blocks – that is, 
# waits until a key is pressed and then returns the key code.  
# Per discussion in lecture, you may wish to return after said key
# is released
KeyGetKey:

    push {r1,r2,r3,lr}
    mov r0, #0
1:
	mov r1, #10
	bl usDelay
    bl KeyGetKeyNoblock

    cmp r0, #0
    beq 1b
2:
# Row = Input | Col = Output
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r3, #0x0055
    bfi r2, r3, #0, #16
    str r2, [r1, #GPIO_MODER]
# "0000" -> ODR (Col)
    ldrb r2, [r1, #GPIO_ODR]
    mov r3, #0x0
    bfi r2, r3, #0, #4
    strb r2, [r1, #GPIO_ODR]
# Store input data in r3
    ldrb r3, [r1, #GPIO_IDR]
    cmp r3, #0xF0
    bne 2b

    pop {r1,r2,r3,pc}


.global KeyGetChar
# Similar to KeyGetkey, but returns the ASCII code corresponding
# to the key press. 
# This method blocks. You should use a data structure in .rodata
# to map keys to characters
KeyGetChar:

    push {r1,r2,lr}

	bl KeyGetKey
	sub r0, #1
	mov r2, r0
	ldr r1, =keyChars
	ldrb r0, [r1, r2]

    pop {r1,r2,pc}

# Waits for input on keypad and returns that value in r0
keypadScan:

    push {r1,r2,r3,lr}
2:
# Row = Input | Col = Output
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r0, #0x0055
    bfi r2, r0, #0, #16
    str r2, [r1, #GPIO_MODER]
# "0000" -> ODR (Col)
    ldrb r2, [r1, #GPIO_ODR]
    mov r3, #0x0
    bfi r2, r3, #0, #4
    strb r2, [r1, #GPIO_ODR]
# Store input data in r3
	mov r0, r1
    mov r1, #5
    bl usDelay
    mov r1, r0
    ldrb r3, [r1, #GPIO_IDR]

# Row = Output | Col = Input
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]
    mov r0, #0x5500
    bfi r2, r0, #0, #16
    str r2, [r1, #GPIO_MODER]
# "0000" -> ODR (Row)
    ldrb r2, [r1, #GPIO_ODR]
    mov r0, #0x0
    bfi r2, r0, #0, #4
    strb r2, [r1, #GPIO_ODR]
    mov r0, r1
    mov r1, #5
    bl usDelay
    mov r1, r0
# Read IDR (Row & Col)
    ldrb r0, [r1, #GPIO_IDR]
    orr r0, r0, r3

    pop {r1,r2,r3,pc}


.section .rodata 
keyChars: 
    .asciz "123A456B789C*0#D"
