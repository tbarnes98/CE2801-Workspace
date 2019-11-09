# lcd.s
# Trevor Barnes
# CE2801-031
# Description: Contains routines for the LCD component

.syntax unified
.cpu cortex-m4
.thumb
.section .text

#Fill in addresses
	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOAEN, 1<<0
    .equ RCC_GPIOCEN, 1<<2

    .equ GPIOA_BASE, 0x40020000
    .equ GPIOC_BASE, 0x40020800 
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_IDR, 0x10
    .equ GPIO_BSRR, 0x18

#What pin is each of these?
	.equ RS, 8 // PC8
	.equ RW, 9 // PC9
	.equ E, 10 // PC10

#Commands for BSRR
	.equ RS_SET, 1<<RS
	.equ RS_CLR, 1<<(RS+16)
	.equ RW_SET, 1<<RW
	.equ RW_CLR, 1<<(RW+16)
	.equ E_SET, 1<<E
	.equ E_CLR, 1<<(E+16)

#Globally exposed functions
.global lcdInit

#Local helper function
PortSetup:
    push {r1,r2,r3}
    #Turn on Ports in RCC
    ldr r1, =RCC_BASE

    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOAEN
    str r2, [r1, #RCC_AHB1ENR]

    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOCEN
    str r2, [r1, #RCC_AHB1ENR]

    #Set DB Pins to Outputs
    ldr r1, =GPIOA_BASE
    ldr r2, [r1, #GPIO_MODER]

    movw r3, 0x5500
    movt r3, 0x0055
    
    orr r2,r2, r3

    movw r3, 0xAA00
    movt r3, 0x00AA
    bic r2, r2, r3

    str r2, [r1, #GPIO_MODER]

    #Set RS RW E Pins to Outputs
    ldr r1, =GPIOC_BASE
    ldr r2, [r1, #GPIO_MODER]

    movw r3, 0x0000
    movt r3, 0x0015
    
    orr r2,r2, r3

    movw r3, 0x0000
    movt r3, 0x00EA
    bic r2, r2, r3
    str r2, [r1, #GPIO_MODER]

	pop {r1,r2,r3}
    bx lr


#Writes instruction
#RS=0 RW=0  R1-Arg
#No returns
WriteInstruction:
	push {r2,r3,lr}

	#Set RS=0,RW=0,E=0

    ldr r2, =GPIOC_BASE

    mov r3, RS_CLR
    str r3, [r2, #GPIO_BSRR]
    mov r3, RW_CLR
    str r3, [r2, #GPIO_BSRR]
    mov r3, E_CLR
    str r3, [r2, #GPIO_BSRR]

	#Set E=1
    mov r3, E_SET
    str r3, [r2, #GPIO_BSRR]

	#Set R1 -> DataBus 
    lsl r1, #4
    ldr r3, =GPIOA_BASE
    ldr r2, [r3, #GPIO_ODR]
    bfc r2, #4, #8
    orr r2, r2, r1
    str r2, [r3, #GPIO_ODR ] 
	#Set E=0
    ldr r2, =GPIOC_BASE
    mov r3, E_CLR
    str r3, [r2, #GPIO_BSRR]

	#Wait for appropriate delay
    mov r1, #37
    bl lcd_delay
	pop {r2,r3,pc}


#Writes data
#RS=0 RW=0  R1-Arg
#No returns
WriteData:
	push {r1,r2,r3,r4,lr}

	#Set RS=1,RW=0,E=0
    ldr r2, =GPIOC_BASE

    mov r3, #RS_SET
    str r3, [r2, #GPIO_BSRR]
    mov r3, #RW_CLR
    str r3, [r2, #GPIO_BSRR]
    mov r3, #E_CLR
    str r3, [r2, #GPIO_BSRR]
	#Set E=1
    mov r3, #E_SET
    str r3, [r2, #GPIO_BSRR]
	#Set R1 -> DataBus 
	lsl r1, #4
    ldr r3, =GPIOA_BASE
    ldr r2, [r3, #GPIO_ODR]
    bfc r2, #4, #8
    orr r2, r2, r1
    str r2, [r3, #GPIO_ODR ] 
	#Set E=0
    ldr r2, =GPIOC_BASE
    mov r3, #E_CLR
    str r3, [r2, #GPIO_BSRR]
	#Wait for appropriate delay
    mov r1, #37
    bl lcd_delay
	pop {r1,r2,r3,r4,pc}

#Code to intialize the lcd
lcdInit:
	push {r0,r1,lr}

    #Set up Ports
    bl PortSetup
    #Wait 40ms
    mov r0, #40
    bl delay_ms
    #Write Function Set (0x38)
    mov r1, 0x38
    bl WriteInstruction
    mov r1, #37
    bl lcd_delay
    #Write Function Set (0x38)
    mov r1, 0x38
    bl WriteInstruction
    mov r1, #37
    bl lcd_delay
    #Write Display On/Off(0x0F)
    mov r1, 0x0F
    bl WriteInstruction
    mov r1, #37
    bl lcd_delay
    #Write Display Clear (0x01)
    mov r1, 0x01
    bl WriteInstruction
    mov r1, #2
    bl delay_ms
    
    #Write Entry Mode Set (0x06)
    mov r1, 0x06
    bl WriteInstruction

    mov r1, #37
    bl lcd_delay
	pop {r0,r1,pc}

.global lcdClear
    # clears the display
    # no arguments or return
    # includes necessary delay
lcdClear:
    push {r0,lr}
    mov r1, 0x01
    bl WriteInstruction
    # Delay for at least 1.52ms
    mov r0, #2
    bl delay_ms
    pop {r0,pc}


.global lcdHome
    # moves cursor to the home position
    # no arguments or return
    # includes necessary delay
lcdHome:
    push {r1,lr}
    mov r1, #0x02
    bl WriteInstruction
    mov r0, #2
    bl delay_ms
    pop {r1,pc}

.global lcdSetPosition
    # moves cursor to the position indicated
    # r0 is the zero-based row and r1 is the zero-based column, no return value
    # includes necessary delay
lcdSetPosition:
    push {r0,r1,lr}
    # Sub values to "actual" positions
    sub r0, r0, #1
    sub r1, r1, #1
    # Shift row to actual
    lsl r0, r0, #6
    orr r0, r0, r1

    mov r1, #0x80
    orr r1, r1, r0
    bl WriteInstruction
    pop {r0,r1,pc}

.global lcdPrintString
    # prints a null terminated string to the display
    # r0 contains the address of the null terminated string (usually located in .data or .rodata), returns the number of characters written to display in r0
    # includes necessary delay
lcdPrintString:
    push {r0,r1,r2,r3,lr}

    mov r2, #0
loop:
    ldrb r1, [r0, r2]
    @ push {r0, r1}
    @ mov r0, #2
    @ mov r1, r2
    @ bl lcdSetPosition
    @ pop {r0, r1}
    cmp r1, #0x00
    beq done
    bl WriteData
    add r2, r2, #1
    b loop
done:
    mov r0, r1
    pop {r0,r1,r2,r3,pc}

.global lcdPrintNum
    # prints a (decimal) number to the display
    # the number to be printed is in r0, values of 0 to 9999 will print, anything above 9999 should print Err.
    # includes necessary delay
lcdPrintNum:
    push {r0,r1,r2,r3,r4,lr}

    bl num_to_ASCII
    # Store num in memory
    ldr r2, =numToPrint
    str r0, [r2]
    # Move cursor to right-most position
    mov r1, #16
writeByte:
    mov r0, #2
    bl lcdSetPosition
    
    mov r4, r0
    mov r0, #1
    bl delay_ms
    mov r0, r4

    mov r0, r1
    ldrb r1, [r2, r3]
    bl WriteData

    mov r4, r0
    mov r0, #1
    bl delay_ms
    mov r0, r4

    add r3, r3, #1
    cmp r3, #4
    sub r1, r0, #1
    cmp r3, #4
    bne writeByte
    pop {r0,r1,r2,r3,r4,pc}

# Takes in a value from 0-9999 and converts it to ASCII
# Input:
#       r0: Input binary value

num_to_ASCII:

    # If outside of range, return ASCII "Err."
    push {r1,r2,r3,lr}

    cmp r0,#0
    blt out_of_range
    ldr r1,=9999
    cmp r0, r1
    bgt out_of_range

# Normal conversion behavior
    mov r1, #16
    lsl r0, #3
    sub r1, #3
shift_cycle:

    lsl r0, #1
    sub r1, #1
    cmp r1, #0
    # Branch to encode section if shifted 16 times
    beq encode

# Verify Each Nibble is less than or equal to 4
    ubfx r2, r0, #16, #4
    # If value is less than or equal to 4, then skip to next nibble
    cmp r2, #4
    ble 2f
    add r2, #3
    bfi r0, r2, #16, #4
2:  ubfx r2, r0, #20, #4
    # If value is less than or equal to 4, then skip to next nibble
    cmp r2, #4
    ble 3f
    add r2, #3
    bfi r0, r2, #20, #4
3:  ubfx r2, r0, #24, #4
    # If value is less than or equal to 4, then skip to next nibble
    cmp r2, #4
    ble 4f
    add r2, #3
    bfi r0, r2, #24, #4
4:  ubfx r2, r0, #28, #4
    # If value is less than or equal to 4 skip to end
    cmp r2, #4
    ble end_verify_nibbles
    add r2, #3
    bfi r0, r2, #28, #4
end_verify_nibbles:

    
    b shift_cycle
encode:
    mov r3, #3
# Encode BCD numbers to ASCII
    # Extract ones nibble
    ubfx r2, r0, #16, #4
    # Insert ones nibble
    bfi r1, r2, #0, #4
    # Insert 3 in front of nibble for ASCII encoding
    bfi r1, r3, #4, #4

    # Extract tens nibble
    ubfx r2, r0, #20, #4
    # Insert tens nibble
    bfi r1, r2, #8, #4
    # Insert 3 in front of nibble for ASCII encoding
    bfi r1, r3, #12, #4

    # Extract hundreds nibble
    ubfx r2, r0, #24, #4
    # Insert hundreds nibble
    bfi r1, r2, #16, #4
    # Insert 3 in front of nibble for ASCII encoding
    bfi r1, r3, #20, #4

    # Extract thousands nibble
    ubfx r2, r0, #28, #4
    # Insert thousands nibble
    bfi r1, r2, #24, #4
    # Insert 3 in front of nibble for ASCII encoding
    bfi r1, r3, #28, #4

    b end_ASCII
out_of_range:
    # Insert ASCII "Err."
    movw r1, #0x722E
    movt r1, #0x4572

end_ASCII:
    # Return value in r0
	mov r0, r1
    pop {r1,r2,r3,pc}


.global lcdBusyWait
# Loops until the busy flag is 0
lcdBusyWait:

    push {r0,r1,r2,r3,lr}

    ldr r1, =GPIOA_BASE
    ldr r2, [r1, #GPIO_MODER]

    mov r3, #0
    
    orr r2, r2, r3

    movw r3, 0xFF00
    movt r3, 0x00FF
    bic r2, r2, r3

    str r2, [r1, #GPIO_MODER]

    #Set RS=0, RW=1, E=1
    ldr r2, =GPIOC_BASE

    mov r3, #RS_CLR
    str r3, [r2, #GPIO_BSRR]
    mov r3, #RW_SET
    str r3, [r2, #GPIO_BSRR]
    mov r3, #E_SET
    str r3, [r2, #GPIO_BSRR]
busy:
	#Set E=
    mov r3, #E_SET
    str r3, [r2, #GPIO_BSRR]
	#Set Databus -> R1
    ldr r3, =GPIOA_BASE
    ldr r1, [r3, #GPIO_IDR]
	#Set E=0
    ldr r2, =GPIOC_BASE
    mov r3, #E_CLR
    str r3, [r2, #GPIO_BSRR]

    mov r2, #0x0010
    and r1, r2
    lsr r1, #4
    # Are we still busy?
    cmp r1, #1
    beq busy

# Return DB port to original mode 
    ldr r1, =GPIOA_BASE
    ldr r2, [r1, #GPIO_MODER]

    movw r3, 0x5500
    movt r3, 0x0055
    
    orr r2,r2, r3

    movw r3, 0xAA00
    movt r3, 0x00AA
    bic r2, r2, r3

    str r2, [r1, #GPIO_MODER]

    pop {r0,r1,r2,r3,pc}


.section .data
numToPrint:
    .word 0