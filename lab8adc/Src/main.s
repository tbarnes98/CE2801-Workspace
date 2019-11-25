# main.s
# Trevor Barnes
# CE2801-031
.syntax unified
.cpu cortex-m4
.thumb
.section .text

    .equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_APB2ENR, 0x44
    .equ GPIOB_EN, 1<<1
    .equ ADC1_EN, 1<<8
    
    .equ GPIOB_BASE, 0x40020400
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    
    .equ ADC1_BASE, 0x40012000
    .equ ADC_SR, 0x00
    .equ ADC_CR2, 0x08
    .equ ADC_SQR3, 0x34
    .equ ADC_DR, 0x4C

.global main
main:

	bl lcdInit
	bl KeyInit
	bl timerInit


	# Enable GPIOB in RCC
	ldr r0, =RCC_BASE
	ldr r1, [r0, #RCC_AHB1ENR]
	orr r1, r1, #GPIOB_EN
	str r1, [r0, #RCC_AHB1ENR]

	# Enable ADC1 in RCC
	ldr r1, [r0, #RCC_APB2ENR]
	orr r1, r1, #ADC1_EN
	str r1, [r0, #RCC_APB2ENR]

	# Temperature Analog on PB0
	ldr r0, =GPIOB_BASE
	ldr r1, [r0, #GPIO_MODER]
	mov r2, #0b11
	bfi r1, r2, #0, #2
	str r1, [r0, #GPIO_MODER]

	# Turn on ADC1
	ldr r0, =ADC1_BASE
	ldr r1, [r0, #ADC_CR2]
	orr r1, r1, #(1<<0)
	str r1, [R0, #ADC_CR2]

	# ADC Channel 8
	ldr r1, [r0, #ADC_SQR3]
	mov r2, #8
	bfi r1, r2, #0, #5
	str r1, [r0, #ADC_SQR3]

mainLoop:

	bl conversionLoop
	bl KeyGetKeyNoblock

	# '*' Buffer on/off
	cmp r0, #13
	beq buffer

	# '#' Set interval (1-9 Seconds)
	cmp r0, #15
	beq setInterval

	# 'B' Set Buffer size [01-99]
	cmp r0, #8
	beq setBufferSize

	# 'D' Toggle Between displaying temperatures in C or F
	cmp r0, #16
	beq toggleTemp

	# 'A' Display Buffered results
	cmp r0, #4
	beq displayBufferedResults

	# 'C' Continuous mode
	cmp r0, #12
	beq continuousMode

	#loop that will finish what chosen option and then ask for another instruction
	b mainLoop

conversionLoop:

	push {r0, r1, lr}

	ldr r0, =ADC1_BASE
	ldr r1, [r0, #ADC_CR2]
	orr r1, r1, #(1<<30)
	str r1, [r0, #ADC_CR2]

1:
	ldr r1, [r0, #ADC_SR]
	ands r1, r1, #(1<<1)
	beq 1b

	pop {r0,r1, pc}


buffer:

	push {lr}



	pop	{pc}

setInterval:

	push {lr}

	# Prompt user for input

	# Store value next typed value on LCD

	# Set interval to stored value

	pop	{pc}

setBufferSize:

	push {lr}

	# Prompt user for two digit input

	# Store the next two typed values on LCD

	# Set buffer size to stored value

	pop	{pc}

toggleTemp:

	push {lr}

	# Alter voltage to degree calculation

	pop	{pc}

displayBufferedResults:

	push {lr}

	# Print whatever the most recent results are

	# Scroll through all items in buffer

	pop	{pc}

continuousMode:

	push {lr}

	# Print periodic results until return button is pushed

	pop	{pc}


bufferedResults:
	.asciz ""

intervalSet:
	.asciz "Type Sample Interval (1-9 seconds):"
interval:
	.byte 0
bufferSize:
	.byte 0
.section .rodata

startMsg:
	.asciz "Select Mode"
