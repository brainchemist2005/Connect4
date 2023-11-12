.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
Board: .word L1 L2 L3 L4 L5 L6

L1: .string ":.......:"
L2: .string ":.......:"
L3: .string ":.......:"
L4: .string ":.......:"
L5: .string ":.......:"
L6: .string ":.......:"

L8: .space 13

errorMsg: .string "Erreur d'entrée.\n"

.text
la s0, Board       # Load base address of Board into s0

lw s1, 0(s0)       # Load the address of the first row into s1
lw s2, 4(s0)       # Load the address of the second row into s2
lw s3, 8(s0)       # Load the address of the third row into s3
lw s4, 12(s0)      # Load the address of the fourth row into s4
lw s5, 16(s0)      # Load the address of the fifth row into s5
lw s6, 20(s0)      # Load the address of the sixth row into s6


main:
    li t5, 1
    li a7, ReadChar  # System call to read a character
    ecall            # Execute the system call

    # Ignore spaces (ASCII 32) and newlines (ASCII 10)
    li t3, 32        # Space character
    beq a0, t3, main # If input is space, read next character
    li t3, 10        # Newline character
    beq a0, t3, main # If input is newline, read next character

    # Check for 'q' to quit the game
    li t3, 'q'
    beq a0, t3, Done

    # Check for 'd' to display game status
    li t3, 'd'
    la t0, Board
    beq a0, t3, gameStatus

    # Check if the input is a valid column number (1-7)
    li t1, '1'       # ASCII for '1'
    li t2, '7'       # ASCII for '7'
    blt a0, t1, inputError  # If input is less than '1', it's an error
    bgt a0, t2, inputError  # If input is greater than '7', it's an error

    # Valid move input, proceed to gameAction
    j gameAction

inputError:
    # Handle invalid input by printing an error message and exiting
    la a0, errorMsg   # Load address of error message
    li a7, PrintString
    ecall
    j Done

gameAction:
    addi a0 ,a0 ,-48
    li t3, '.'

# Set up a pointer to the first row
la t0, Board
li t5, 0        # Initialize row counter

# Loop through the rows
rowLoop:
    
    lw t4, 0(t0)  # Load the address of the current row into t4
    add t4, t4, a0  # Add the column offset to the row address
    lb t1, 0(t4)   # Load the byte at the calculated address into t1
    beq t1, t3, slotFound  # If the byte is '.', the slot is available

    # Increment the row counter and move to the next row if we haven't checked all rows
    addi t5, t5, 1
    li t4, 7        # Total number of rows
    bge t5, t4, done  # If we've checked all rows, exit the loop
    addi t0, t0, 4  # Otherwise, move to the next row
    li a7,1
    ecall
    j rowLoop

    done:
    j main

slotFound: 
    # Determine the symbol ('X' or 'O') based on the value of t6 (player's turn)
    li t4, 'X'
    li t5, 'O'
    li t2, 2  # Store the value 2 in t2

    # Check if t6 is even or odd
    rem t2, t6, t2  # t2 will be 0 if t6 is even, 1 if t6 is odd

    # Calculate the symbol to use
    beqz t2, setX  # If t2 is 0 (even), jump to setX
    mv t4, t5      # If t6 is odd, set t4 to 'O'
    # Note: The "setO" label has been removed as it is not necessary with the above logic

setX:
    # If t6 is even, t4 is already 'X'
    # t4 now contains the correct character ('X' or 'O')

updateSlot:
    # t4 now contains the character 'X' or 'O' to store.
    # t0 must contain the base address of the row.
    # a0 contains the column offset.
    
      # Add the column offset to the base address of the row to get the exact slot address.
    
    lw t1, 0(t0)
    add t1, t1, a0  # Add the offset in a0 to the base address in s1, store result in t0
    sb t4, 0(t1)       # Store the 'X' or 'O' at the address in t0.

    addi t6, t6, 1   # Increment the player's turn counter.
    j main



gameStatus:
    li t4, 7
    li t3, '\n'
    li a7, PrintChar
    mv a0, t3
    ecall
    li a7, PrintString
    lw a0 ,20(t0)
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
