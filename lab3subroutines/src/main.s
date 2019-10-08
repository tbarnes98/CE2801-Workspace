# main.s
# Trevor Barnes
# CE2801-031
# Lab 3: Subroutines
# Description:

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main

main:
	mov r0, #0
	mov r1, #0
	mov r2, #0

main_loop:

    mov r0, #1234
    bl num_to_ASCII
    mov r1, r0
    # r1 is 4 character ASCII value
    mov r0, #500
    # Display 1
   	ubfx r0, r1, #24, #8
    bl num_to_LED
    mov r0, #500
    bl delay_ms
    # Display 2
    ubfx r0, r1, #16, #8
    bl num_to_LED
    mov r0, #500
    bl delay_ms
    # Display 3
    ubfx r0, r1, #8, #8
    bl num_to_LED
    mov r0, #500
    bl delay_ms
    # Display 4
    ubfx r0, r1, #0, #8
    bl num_to_LED
    mov r0, #500 
    bl delay_ms
    b main_loop


end:
    b end
.global num_to_ASCII

# Takes in a value from 0-9999 and converts it to ASCII
# Input:
#       r0: Input binary value
# Output:
#       r1: Output 4 ASCII characters
num_to_ASCII:

    # If outside of range, return ASCII "Err."
    push {r1,r2,r3,lr}

    cmp r0,#0
    blt out_of_range
    @ cmp r0,#9999
    @ bgt out_of_range

    # Normal conversion behavior
    mov r1, #16
    lsl r0, #3
    sub r1, #3
shift_cycle:

    lsl r0, #1
    sub r1, #1

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

    # If value hasn't been shifted 16 times, shift again
    cmp r1, #0
    bne shift_cycle
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
	mov r0, r1
    pop {r1,r2,r3,lr}
    bx lr
