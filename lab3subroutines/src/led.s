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
