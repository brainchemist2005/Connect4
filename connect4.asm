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
li t0, '\n'
la a0, Board
lw a1, (a0)
lw a2, 4(a0)
lw a3, 8(a0)
lw a4, 12(a0)
lw a5, 16(a0)
lw a6, 20(a0)
lw a7, 24(a0)

li t1, 'X'
li t2, 'O'


main:
    li t3, 'd'
    li t6, 1  # Counter to keep track of player's turn
    
    li a7, ReadChar
    ecall
    
    beq a0, t3, gameStatus
    li t3, 'q'
    beq a0, t3, Done
    bgtz a0,gameActionCheck
    j Done

gameActionCheck:
    li t3 , 8
    bgt a0, t3, Done
    jal gameAction

gameAction:
    li t3, '.'
    addi t6, t6, 1
    
    # Set up a pointer to the first row
    add t8, a1, x0


    # Loop through the rows
    rowLoop:
        beqz t8, done  # Exit the loop if the pointer is null (end of rows)

        # Check the 3rd slot in the current row for '.'
        lb t9, 2(t8)
        beq t9, t3, slotFound  # If the 3rd slot contains '.', jump to slotFound

        # Move to the next row
        lw t8, 4(t8)
        j rowLoop

    done:
    j main
    
slotFound: 
    slotFound:
    # Determine the symbol ('X' or 'O') based on the value of t6 (player's turn)
    li t4, 'X'
    li t5, 'O'
    
    # Check if t6 is even or odd
    rem t7, t6, 2  # t7 will be 0 if t6 is even, 1 if t6 is odd

    # Calculate the symbol to use
    beqz t7, setX  # If t7 is 0 (even), jump to setX
    setO:
        mv t4, t5  # If t6 is odd, set t4 to 'O'
        j updateSlot

    setX:
        # If t6 is even, t4 is already 'X'

    updateSlot:
        # Update the 3rd character of the current row with the chosen symbol (t4)
        sb t4, 2(a1)
        
    j main

gameStatus:
	li a7, PrintChar
	mv a0, t0
	ecall
	li a7, PrintString
	mv a0, a1
	ecall
	li a7, PrintChar
	mv a0, t0
	ecall
	li a7, PrintString	
	mv a0, a2
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, a3
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, a4
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, a5
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, a6
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	j inGame
	
Done:
	li a7,Exit
	ecall
