	.syntax unified
	.cpu cortex-m4
	.thumb
	.section
	.text

	.global timerInit
timerInit:
	push {r0-r4, lr}
    #Alt func low reg for TIM3
    ldr r1, [r0, #AFRL_OFFSET]
    bic r1, #16, #4
    orr r1, r1, #AFRL_TIM3_CH1_EN
    str r1, [r0, #AFRL_OFFSET]

    #Enable CCMR1 for preload and set pwm
    #Allows for the modification of the pulse
    ldr r0, =TIM3_BASE
    ldr r1, [r0, #CCMR_OFFSET]
    bfc r1, #4, #3
    mov r2, #CCMR_OCC1M_PWM
    orr r2, r2, #CCMR_OCC1PE
    orr r1, r1, r2
    str r1, [r0, #CCMR_OFFSET]

	#Enable CCER to for TIM3 (TIC)
	#Every 10 seconds, sample


	pop{r0, r4}
	bx lr
