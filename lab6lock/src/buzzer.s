# buzzer.s
# Trevor Barnes
# CE2801-031

.syntax unified
.cpu cortex-m4
.thumb
.section .text

    .equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ APB1ENR_OFFSET, 0x40
    .equ GPIOB_BASE, 0x40020400
    .equ GPIOB_EN, 0x2
    .equ TIM3_BASE, 0x40000400
    .equ TIM3_EN, 1<<1
    .equ GPIO_MODER, 0x0

    .equ PB4_ALT_FUNCTION, 1<<9
    .equ AFRL_OFFSET, 0x20
    .equ AFRL_TIM_3_CH_1_EN, 1<<17

    .equ CCMR_OFFSET, 0x18
    .equ CCMR_OCC1PE, 1<<3
    .equ CCMR_OCC1M_PWM, 0b1110000

    .equ CCER_OFFSET, 0x20
    .equ CCER_CC1E, 1

    .equ EGR_OFFSET, 0x14
    .equ EGR_UG, 1

    .equ PSC_OFFSET, 0x28
    .equ ARR_OFFSET, 0x2C
    .equ CCR1_OFFSET, 0x34

    .equ CR1_OFFSET, 0x00
    .equ CR_ARPE_EN, 1<<7
    .equ CR_CEN, 1

    .equ mil, 1000000

.global piezoInit
piezoInit:
    push {r0-r2}

	# Enable GPIOB and Timer 3 in RCC
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_AHB1ENR]
    orr r1, r1, #GPIOB_EN
    str r1, [r0,#RCC_AHB1ENR]
    ldr r1, [r0, #APB1ENR_OFFSET]
    orr r1, r1, #TIM3_EN
    str r1, [r0, #APB1ENR_OFFSET]

	# Set Mode to alternate function
    ldr r0, =GPIOB_BASE
    ldr r1,[r0, #GPIO_MODER]
    bic r1, r1, #1<<8
    orr r1, r1, #PB4_ALT_FUNCTION
    str r1, [r0, #GPIO_MODER]

    # Set Alternate function low register to timer 3.
    ldr r1, [r0, #AFRL_OFFSET]
    bic r1, #16, #4
    orr r1, r1, #AFRL_TIM_3_CH_1_EN
    str r1, [r0, #AFRL_OFFSET]

    # Configure CCMR1 to enable preload and set to pwm
    ldr r0, =TIM3_BASE
    ldr r1, [r0, #CCMR_OFFSET]
    bfc r1, #4, #3
    mov r2, #CCMR_OCC1M_PWM
    orr r2, r2, #CCMR_OCC1PE
    orr r1, r1, r2
    str r1, [r0, #CCMR_OFFSET]

	#C onfigure CCER to enable timer 3 as output capture
    ldr r1, [r0, #CCER_OFFSET]
    mov r2, #CCER_CC1E
    orr r1, r1, r2
    str r1, [r0, #CCER_OFFSET]

	# Configure control register to enable preload
    ldr r1, [r0, #CR1_OFFSET]
    mov r2, #CR_ARPE_EN
    orr r1, r1, r2
    str r1, [r0, #CR1_OFFSET]
    pop {r0-r2}
    bx lr

    # Turns the piezo buzzer on
    .global piezoOn
piezoOn:
    push {r0-r2}
    ldr r0, =TIM3_BASE
    ldr r1, [r0, #CR1_OFFSET]
    mov r2, #CR_CEN
    orr r1, r1, r2
    str r1, [r0, #CR1_OFFSET]
    pop {r0-r2}
    bx lr


    # Turns the piezo buzzer off
    .global piezoOff
piezoOff:
    push {r0-r2}
    ldr r0, =TIM3_BASE
    ldr r1, [r0, #CR1_OFFSET]
    mov r2, #CR_CEN
    bic r1, r1, r2
    str r1, [r0, #CR1_OFFSET]
    pop {r0-r2}
    bx lr

    # r0 contains frequency (hz)
    .global piezoSetFrequency
piezoSetFrequency:
    push {r0-r3}
    ldr r3, =TIM3_BASE
    mov r1, #15
    str r1, [r3, #PSC_OFFSET]
    ldr r1, =mil
    udiv r0, r1, r0
    str r0, [r3, #ARR_OFFSET]
    lsr r0, #1
    ldr r2, [r3, #CCR1_OFFSET]
    bfc r2, #0, #16
    orr r2, r2, r0
    str r2, [r3, #CCR1_OFFSET]
    ldr r2, [r3, #EGR_OFFSET]
    mov r2, #EGR_UG
    strb r2, [r3, #EGR_OFFSET]
    pop {r0-r2, r3}
    bx lr
