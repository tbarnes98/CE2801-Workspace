# main.s
# Trevor Barnes
# CE2801-031

	.syntax unified
    .cpu cortex-m4
    .thumb
    .section .text

	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_ODR, 0x14
	.equ GPIO_BSRR, 0x18

	# Code is '2801'
	.equ char1, 2 // 2
	.equ char2, 10 // 8
	.equ char3, 14 // 0
	.equ char4, 1 // 1

    .global main

main:

	bl lcdInit
	bl KeyInit
	bl ledInit
	bl piezoInit

mainLoop:
	mov r0, #200
	bl msDelay
	ldr r0, =msg
	bl lcdPrintString

	# How many characters have been entered
	mov r8, #0
	# How many characters are correct
	mov r9, #0

# Coded as '2' button
firstchar:
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #char1
	beq correctchar

# Coded as '8' button
secondchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #char2
	beq correctchar

# Coded as '0' button
thirdchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #char3
	beq correctchar

# Coded as '1' button
fourthchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #char4
	beq correctchar

	b incorrect

correctchar:
	add r9, r9, #1
	cmp r8, #1
	beq secondchar
	cmp r8, #2
	beq thirdchar
	cmp r8, #3
	beq fourthchar
	cmp r8, #4
	beq determine

determine:
	cmp r9, #4
	beq unlock

	b incorrect

unlock:

	# Correct buzzer sound
	mov r0, 1000
	bl piezoSetFrequency
	bl piezoOn

	bl lcdClear
	mov r0, #20
	bl msDelay
	ldr r0, =correct
	bl lcdPrintString

	mov r3, #0x10000

scroll_right:
	ldr r1, =GPIOB_BASE
    # Move ON bit one position to the right
    lsr r3, r3, #1
    # Read current data
    ldr r2, [r1, #GPIO_ODR]
    # Write new data
    orr r2, r2, r3
    # Skip if PB11 "pin"
    cmp r3, 0x0800
    beq scroll_right
    # Write data back
    str r2, [r1, #GPIO_ODR]
    # Write the current ON bit to be cleared next cycle
    mov r4, r3

	mov r0, #100
    bl msDelay
    # Loop back until the rightmost pin is on
    cmp r3, 0x0020
    bne scroll_right

	mov r0, #1000
	bl msDelay

	# Turn off leds
	ldr r0, =GPIOB_BASE
	mov r2, #0xF7F0
	ldr r1, [r0, #GPIO_BSRR]
	bfi r1, r2, #16, #16
	str r1, [r0, #GPIO_BSRR]

	bl lcdClear
	bl piezoOff

	b mainLoop

incorrect:

	# Incorrect buzzer sound
	mov r0, 300
	bl piezoSetFrequency
	bl piezoOn

	bl lcdClear
	mov r1, #20
	bl msDelay
	ldr r0, =invalid
	bl lcdPrintString

	mov r0, #1000
	bl msDelay

	bl lcdClear
	bl piezoOff

	b mainLoop

.section .data

msg: .asciz "Password:"
correct: .asciz "Correct"
invalid: .asciz "Incorrect"
star: .asciz "*"
