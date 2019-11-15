# main.s
# Trevor Barnes
# CE2801-031

	.syntax unified
    .cpu cortex-m4
    .thumb
    .section .text

	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_ODR, 0x14
	.equ BSRR, 0x18

    .global main

main:

	bl lcdInit
	bl KeyInit
	bl ledInit
	bl piezoInit

top:
	mov r0, #200
	bl msDelay
	ldr r0, =msg
	bl lcdPrintString

	# How many characters have been entered
	mov r8, #0
	# How many characters are correct
	mov r9, #0

firstchar:
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #2 //2
	beq correctchar

secondchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #10 //'8'
	beq correctchar

thirdchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #14 //'0'
	beq correctchar

fourthchar:
	ldr r0, =star
	bl lcdPrintString
	bl KeyGetKey
	add r8, r8, #1
	cmp r0, #1 //'1"
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
	#Check if the number of correct bits is 4
	cmp r9, #4
	beq unlock

	b incorrect

unlock:
	#Turn open LED
	@ ldr r0, =GPIOB_BASE
	@ mov r2, #0xC060
	@ ldr r1, [r0, #BSRR]
	@ orr r1, r1, r2
	@ str r1, [r0, #BSRR]

	#Buzz buzzer
	mov r0, 1000
	bl piezoSetFrequency
	bl piezoOn

	#Print CORRECT
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
    # Clear previous ON bit, default 0
    @ bic r2, r4
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

	

	#Wait and show message and leds
	mov r0, #1000
	bl msDelay

	#Turn off leds
	ldr r0, =GPIOB_BASE
	mov r2, #0xF7F0
	ldr r1, [r0, #BSRR]
	bfi r1, r2, #16, #16
	str r1, [r0, #BSRR]

	#Clear
	bl lcdClear
	bl piezoOff

	b top

incorrect:

	#Buzz buzzer
	mov r0, 300
	bl piezoSetFrequency
	bl piezoOn

	#Print INCORRECT
	bl lcdClear
	mov r1, #20
	bl msDelay
	ldr r0, =invalid
	bl lcdPrintString

	#Wait to show message
	mov r0, #1000
	bl msDelay

	#Clear
	bl lcdClear
	bl piezoOff

	b top

.section .data

msg: .asciz "Password:"
correct: .asciz "Correct"
invalid: .asciz "Incorrect"
star: .asciz "*"
