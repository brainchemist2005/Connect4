.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
Board: .word L1 L2 L3 L4 L5 L6 L7

L1: .string ":.......:"
L2: .string ":.......:"
L3: .string ":.......:"
L4: .string ":.......:"
L5: .string ":.......:"
L6: .string ":.......:"
L7: .string ":.......:"
L8: .space 13

.text
la s0, Board
lw s1, 24(s0)
lw s2, 20(s0)
lw s3, 16(s0)
lw s4, 12(s0)
lw s5, 8(s0)
lw s6, 4(s0)
lw s7, (s0)

main:
    li t3, 'd'
    li t6, 1  # Counter to keep track of the player's turn
    
    li a7, ReadChar
    ecall
    
    beq a0, t3, gameStatus
    li t3, 'q'
    beq a0, t3, Done
    bgtz a0, gameActionCheck
    j Done

gameActionCheck:
    li t3, 56
    bgt a0, t3, Done
    jal gameAction

gameAction:
    li t3, '.'

    # Set up a pointer to the first row
    add t0, s0, x0

    # Loop through the rows
    rowLoop:
        beqz t0, done  # Exit the loop if the pointer is null (end of rows)

        # Check the 3rd slot in the current row for '.'
        lb t1, 2(t0)
        beq t1, t3, slotFound  # If the 3rd slot contains '.', jump to slotFound

        # Move to the next row
        lw t0, 4(t0)
        j rowLoop

    done:
    j main

slotFound: 
    # Determine the symbol ('X' or 'O') based on the value of t6 (player's turn)
    li t4, 'O'
    li t5, 'X'
    li t2, 2  # Store the value 2 in t2

    # Check if t6 is even or odd
    rem t2, t6, t2  # t2 will be 0 if t6 is even, 1 if t6 is odd

    # Calculate the symbol to use
    beqz t2, setX  # If t2 is 0 (even), jump to setX
    setO:
        mv t4, t5  # If t6 is odd, set t4 to 'O'
        j updateSlot

    setX:
        # If t6 is even, t4 is already 'X'

updateSlot:
    # Update the 3rd character of the current row with the chosen symbol (t4)
    sb t4, 2(t0)
    addi t6, t6, 1  # Increment the player's turn counter
    j main

gameStatus:
    li t0, '\n'
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s1
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s2
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s3
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s4
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s5
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    li a7, PrintString
    mv a0, s6
    ecall
    li a7, PrintChar
    mv a0, t0
    ecall
    j main

Done:
    li a7, Exit
    ecall
