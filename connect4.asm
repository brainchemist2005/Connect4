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
    addi sp , sp , -44
    # Set t4 to the current player's symbol ('X' or 'O')
    li t2, 2
    rem t2, t6, t2
    beqz t2, playerX
    li t4, 'O'
    playerX:
    li t4, 'X'
    li t2, 0
    sw ra, 0(sp)  # Save the return address
    sw s0, 4(sp)  # Save the board base address
    sw t4, 8(sp)  # Save the current player's symbol ('X' or 'O')
    sw t6, 12(sp) # Save the current player's turn counter
    sw a0, 16(sp) # Save the current column position
    sw t2, 24(sp) # match  counter
    sw t2, 28(sp)
    li t2, 1
    sw t2, 32(sp)
    li t2, 7
    sw t2, 36(sp)
    li t2, 4
    sw t2, 40(sp)
    #jal checkHorizontalWin
    jal checkVerticalWin
    #jal checkDiagonalWinLTR
    #jal checkDiagonalWinRTL
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw t4, 8(sp)
    lw t6, 12(sp)
    lw t1, 16(sp)
    lw t2, 28(sp)
    
    beqz t2 , playerWins

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
    lw s1, 16(sp)  # Initialize column index
vertical_col_loop:
    li t5, 0  # Initialize match counter
    lw t3, 0(sp)
    
vertical_row_check:
    slli t6, s9, 2  # Calculate row offset

    add t3, s0, t6  # Calculate address of the start of the row
    lw a0, (t3)
    li a7, PrintString
    ecall
   # add t3, t3, s1  # Calculate address of the current cell
    lw a0, 1(t3)
    li a7, PrintChar
    ecall
    
    lb x4, 0(t3)    # Load the content of the cell
    bne t4 , x4, main
increment_vertical_counter:
    lw x4, 32(sp)
    lw x6, 40(sp)
    addi t5, t5, 1  # Increment match counter
    beq t5, x6, playerWins  # If there are four in a column, player wins
    addi s9, s9, -1  # Move to the next cell in the column
    bge s2 , x4 , vertical_row_check
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw t4, 8(sp)
    lw t6, 12(sp)
    lw t1, 16(sp)
    lw t2, 28(sp)
    blt s2, x4, main # Check the next cell in the column
    addi sp ,sp , 44
    jr ra  # Return to the main checkWin routine

# Player wins
playerWins:
    addi sp, sp, 44
    li x1, 2
    rem t2 , t6 , x1
    beqz t2 , winX

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
