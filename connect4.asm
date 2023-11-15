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

errorMsg: .string "Erreur d'entrée.\n"
Xloses : .string "Le joueur X perd."
Oloses : .string "Le joueur O perd."
Xturn : .string "Au joueur X de jouer."
Oturn : .string "Au joueur O de jouer."
Xwon : .string "Le joueur X gagne."
Owon : .string "Le joueur O gagne."

.text

la s0, Board       # Load base address of Board into s0

lw s1, 0(s0)       # Load the address of the first row into s1
lw s2, 4(s0)       # Load the address of the second row into s2
lw s3, 8(s0)       # Load the address of the third row into s3
lw s4, 12(s0)      # Load the address of the fourth row into s4
lw s5, 16(s0)      # Load the address of the fifth row into s5
lw s6, 20(s0)      # Load the address of the sixth row into s6
lw s7 , 24(s0)

main:
    li t5, 1
    li a7, ReadChar  # System call to read a character
    ecall            # Execute the system call

    mv s10 , a0
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

li s8, 0
li s9 ,0

# Loop through the rows
rowLoop:
    addi s8 , s8 ,1
    lw t4, 0(t0)  # Load the address of the current row into t4
    add t4, t4, a0  # Add the column offset to the row address
    lb t1, 0(t4)   # Load the byte at the calculated address into t1
    beq t1, t3, slotFound  # If the byte is '.', the slot is available

    # Increment the row counter and move to the next row if we haven't checked all rows
    addi t5, t5, 1
    li t4, 7        # Total number of rows
    bge t5, t4, done  # If we've checked all rows, exit the loop
    addi t0, t0, 4  # Otherwise, move to the next row
    addi s9 ,s9 ,1
    j rowLoop

    done:
    j main
    
checkWin:
    # Save registers that will be used
    # Set t4 to the current player's symbol ('X' or 'O')
    li t2, 2
    rem t2, t6, t2
    bnez t2, playerX
    li t4, 'O'
    j player0
    
    playerX:
    li t4, 'X'
    
    player0:
    li t2, 0
    
    #jal checkHorizontalWin
    j checkVerticalWin
    #jal checkDiagonalWinLTR
    #jal checkDiagonalWinRTL

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
    li x1, 7
    lw t1, 0(t0)
    add t1, t1, a0  # Add the offset in a0 to the base address in s1, store result in t0
    sb t4, 0(t1)       # Store the 'X' or 'O' at the address in t0.

    addi t6, t6, 1   # Increment the player's turn counter.
    beq s8 , x1,overflow

    j checkWin

# checkVerticalWin Subroutine
checkVerticalWin:
    mv s1, a0  # Initialize column index
vertical_col_loop:
    li t5, 0  # Initialize match counter
    la t3, Board
    li x4, 10
vertical_row_check:
    lw x1 , 0(t3)
    mul x5, s9, x4   # Calculate row offset
    add x1, x1, x5     # Calculate address of the start of the row
    add x1, x1, s1     # Add column index to get the address of the current cell
    lb t1, 0(x1)       # Load the byte at the current cell into a0
    mv a0, t4
    li a7, PrintChar
    ecall
    beq t4 , t1, increment_vertical_counter
    
    j main 

increment_vertical_counter:
    li x6 , 4
    addi t5, t5, 1    # Increment match counter

    mv a0, t5
    li a7, 1
    ecall

    beq t5, x6, playerWins  # If there are four in a column, player wins

    # You should check if you've reached the bottom of the column before incrementing s9.
    addi s9, s9, -1   # Decrement to move to the next cell in the column

    bge s9, x4, end_vertical_check  # Check row bounds
    j vertical_row_check


end_vertical_check:
    # Restore stack and registers
    beqz t6, vertical_col_loop  # If flag is not set, continue loop
    j main  # Return to the caller
# Player wins
playerWins:
    li x1, 2
    rem t2 , t6 , x1
    bnez t2 , winX

winO:
	la a0, Owon
	li a7, PrintString
	ecall
	j Done
	
winX:
	la a0, Xwon
	li a7, PrintString
	ecall
	j Done	

overflow:
	li t5, 1
	la t0, Board
	li x2 , 2
	rem x2,t6 ,x2
	li x0, 0
	j gameStatus
	
Xlost:
	beq x2, x0, Olost
	la a0 , Xloses
	li a7 ,PrintString
	ecall
	j Done
	
Olost:
	la a0 , Oloses
	li a7 ,PrintString
	ecall
	j Done
	
gameStatus:
    li x1, 7
    li t4, 8
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
    beq s8 , x1, Xlost
    li x1 , 2
    rem x2, t6,x1
    beqz x2, XTurn
    la a0 , Oturn
    li a7, PrintString
    ecall
    j main
    XTurn:
    la a0 , Xturn
    li a7, PrintString
    ecall
    j main

Done:
    li a7, Exit
    ecall
