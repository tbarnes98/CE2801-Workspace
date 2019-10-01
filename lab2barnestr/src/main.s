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

    # Base GPIOB Location
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

    # Set the starting on bit (one less than the right most LED bit)
    movw r3, #0x0010

scroll_left:
    # Move ON bit one position to the left
    lsl r3, r3, #1
    # Read current data
    ldr r2, [r1, #GPIO_ODR]
    # Clear previous ON bit, default 0
    bic r2, r4
    # Write new data
    orr r2, r2, r3
    # Skip if PB11 "pin"
    cmp r3, 0x0800
    beq scroll_left
    # Write data back
    str r2, [r1, #GPIO_ODR]
    # Write the current ON bit to be cleared next cycle
    mov r4, r3
    bl delay
    # Loop back until the leftmost pin is on
    cmp r3, 0x8000
    bne scroll_left

scroll_right:
    # Move ON bit one position to the right
    lsr r3, r3, #1
    # Read current data
    ldr r2, [r1, #GPIO_ODR]
    # Clear previous ON bit, default 0
    bic r2, r4
    # Write new data
    orr r2, r2, r3
    # Skip if PB11 "pin"
    cmp r3, 0x0800
    beq scroll_right
    # Write data back
    str r2, [r1, #GPIO_ODR]
    # Write the current ON bit to be cleared next cycle
    mov r4, r3
    bl delay
    # Loop back until the rightmost pin is on
    cmp r3, 0x0020
    bne scroll_right
    b scroll_left

delay:
    # Arbitrary delay length
    ldr r12, =0x00050000
1:
    subs r12, r12,#1
    # Branch backward to local label if not equal to 0
    bne 1b
    bx lr

