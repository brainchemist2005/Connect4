.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
Board: .dword L1 L2 L3 L4 L5 L6 L7

L1: .dword ":.......:"
L2: .dword ":.......:"
L3: .dword ":.......:"
L4: .dword ":.......:"
L5: .dword ":.......:"
L6: .dword ":.......:"
L7: .dword ":.......:"
L8: .space 13

.text
la s0, Board
ld s1, 24(s0)
ld s2, 20(s0)
ld s3, 16(s0)
ld s4, 12(s0)
ld s5, 8(s0)
ld s6, 4(s0)
ld s7, 0(s0)

main:
    li t3, 'd'
    li t6, 1  # Counter to keep track of the player's turn
    
    li a7, ReadChar
    ecall
    
    la t0, Board
    li t5, 1
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
    la t0, Board

    # Loop through the rows
    rowLoop:
        beqz t0, done  # Exit the loop if the pointer is null (end of rows)

        # Check the 3rd slot in the current row for '.'
        lb t1, 2(t0)
        beq t1, t3, slotFound  # If the 3rd slot contains '.', jump to slotFound

        # Move to the next row
        addi t0,t0,4
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
    li a0, 0
    add a0, a0,t4
    li a7, PrintChar
    ecall
    sb t4, 2(t0)
    addi t6, t6, 1  # Increment the player's turn counter
    j main


gameStatus:
    li t4, 7
    li t3, '\n'
    li a7, PrintChar
    mv a0, t3
    ecall
    li a7, PrintString
    lw a0 ,24(t0)
    ecall
    addi t0,t0,-4
    addi t5 ,t5 ,1
   blt t5 , t4, gameStatus
   li t3, '\n'
    li a7, PrintChar
    mv a0, t3
    ecall
   j main

Done:
    li a7, Exit
    ecall
