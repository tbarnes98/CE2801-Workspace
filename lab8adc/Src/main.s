	.syntax unified
	.cpu cortex-m4
	.thumb
	.section
	.text

	.global main
main:

	#initialize components
	bl lcdInit
	bl keyInit
	bl timerInit
	#bl adc_init

#Send a single character to adjust the mode of the datalogger
# ['1']['2']['3']['A']  |1  2  3  4 |
# ['4']['5']['6']['B']  |5  6  7  8 |
# ['7']['8']['9']['C']  |9  10 11 12|
# ['*']['0']['#']['D']  |13 14 15 16|


1:	bl keyGetkeyNoblock

	# '*' Buffer on/off
	cmp r0, #13
	beq buffer

	# '#' Set interval (1-9 Seconds)
	cmp r0, #15
	beq setInterval

	# 'B' Set Buffer size [01-99]
	cmp r0, #8
	beq setBufferSize

	# 'D' Toggle Between displaying temperatures C or F
	cmp r0, #16
	beq toggleTemp

	# 'A' Display Buffered results
	cmp r0, #4
	beq displayBufferedResults

	# 'C' Continuous mode
	cmp r0, #12
	beq continuousMode

	#loop that will finish what chosen option and then ask for another instruction
	b 1b
