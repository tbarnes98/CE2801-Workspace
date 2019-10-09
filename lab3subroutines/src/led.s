# led.s
# Trevor Barnes
# CE2801-031
# Description: A file for handling the LED pins on the Dev Board

# Lights are on PB5-PB15 except PB11

.syntax unified
.cpu cortex-m4
.thumb
.section .text

    # Base RCC
    .equ RCC_BASE, 0x40023800
    # GPIOB Enable Register
    .equ RCC_AHB1ENR, 0x30
    # GPIOB Enable
    .equ RCC_GPIOBEN, 1<<1

    # Base GPIOB Location
    .equ GPIOB_BASE, 0x40020400
    # GPIO Mode Register
    .equ GPIO_MODER, 0x00
    # GPIO Output Data Register
    .equ GPIO_ODR, 0x14

.global num_to_LED_init
# Initializes the GPIO port pins to be outputs
num_to_LED_init:
    
    # Store registers before use
    push {r1,r2,r3}

    
    ldr r1, =RCC_BASE

    # Read, Modify, Write
    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOBEN
    str r2, [r1, #RCC_AHB1ENR]

    # Enable PB5-PB10, PB12-PB15 to be outputs

    ldr r1, =GPIOB_BASE

    ldr r2, [r1, #GPIO_MODER]

    movw r3, #0x5400
    movt r3, #0x5515
    orr r2, r2, r3

    movw r3, #0xA800
    movt r3, #0xAA2A
    bic r2, r2, r3

    str r2, [r1, #GPIO_MODER]

    # Return the original register values
    pop {r1,r2,r3}
    # Branch back to link location
    bx lr

.global num_to_LED
# Takes in a 10-bit value and displays it on the LEDs in binary
# Input:
#       r0: Input binary value
num_to_LED:

    push {r1,r2,lr}

    bl num_to_LED_init
    # Extract "pre-PB11" bit field
    ubfx r1, r0, #0, #6
    # extract "post-PB11" bit field
    ubfx r2, r2, #6, #4
    # Clear input register
    mov r0, #0
    # Insert bit field PB5-PB10
    bfi r0, r1, #5, #6
    # Insert bit field PB12-PB15
    bfi r0, r2, #12, #4

    # Clear register values before use
    mov r1, #0
    mov r2, #0
    ldr r1, =GPIOB_BASE

    ldr r2,[r1,#GPIO_ODR]
    bfc r2,#0,#16
    str r2,[r1,#GPIO_ODR]

    ldr r2,[r1,#GPIO_ODR]
    orr r2,r2,r0
    str r2,[r1,#GPIO_ODR]

    pop {r1,r2,pc}
    bx lr
