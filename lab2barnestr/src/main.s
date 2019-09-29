# main.s
# Trevor Barnes
# CE2801-031
# Lab 2: Knight Rider Lights
# Description: This routine causes the lights on the demo board to move in a back and forth
#              pattern like the lights from Knight Rider

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
    # Bit Set Reset Register
    .equ GPIOx_BSRR, 0x18

    .equ GPIOB_BASE, 0x40020400
    # GPIO Mode Register
    .equ GPIO_MODER, 0x00
    # GPIO Output Data Register
    .equ GPIO_ODR, 0x14

.global main

main:

    # Turn on GPIOB in RCC
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

turn_on:
    # Turn on all lights
    ldr r2, [r1, #GPIO_ODR]
    movw r3, #0xF7E0
    orr r2, r2, r3
    str r2, [r1, #GPIO_ODR]

    # Wait
    bl delay
    
    # Turn off all lights
    ldr r2, [r1, #GPIO_ODR]
    movw r3, #0xF7E0
    orr r2, r2, r3
    str r2, [r1, #GPIO_ODR]
    # Wait

    # Go back to turn on al lights
    b turn_on

delay:
    ldr r12, =0x002000000
1:

    subs r12, r12,#1
    # Bracnch backward to local label if not equal to 0
    bne 1b
    bx lr
end:
    b end
