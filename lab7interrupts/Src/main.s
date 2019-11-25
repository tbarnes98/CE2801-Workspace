# main.s
# Trevor Barnes
# CE2801-031

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main
main:

	bl lcdInit
	bl KeyInit
	bl timerInit

	# Round count
	mov r6, #0
mainLoop:

	add r6, #1
	beq showFastest

	# Start timer

	# Prompt user to push button to start (for random seed)

	# Store random hex value

	# Count down on lcd

	# Print random hex value

	# Start Timer

	# Wait for button push interrupt

	# Compare time with previous time, if faster than store it


	b mainLoop

showFastest:

	# Load fastTime

	# Print the fastest time on LCD

	# Wait for button push back to go back to reset round counter and branch back to mainLoop

	mov r6, #0


.global EXTI_BUTTON_PUSH

.thumb_func
EXTI_BUTTON_PUSH:

	# Compare button pushed value and stored random

	# If they are equal, stop timer else branch past

	bx lr

.section .data
fastTime:
	.word 0
