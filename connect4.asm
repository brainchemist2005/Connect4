.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
Board: .word L1 L2 L3 L4 L5 L6

L1 : .string  ":.......:"
L2 : .string  ":.......:"
L3 : .string  ":.......:"
L4 : .string  ":.......:"
L5 : .string  ":.......:"
L6 : .string  ":.......:"

.text
li t0,'\n'
la s0,Board
lw s1, (s0)
lw s2, 4(s0)
lw s3, 8(s0)
lw s4, 12(s0)
lw s5, 16(s0)
lw s6, 20(s0)

li t1,'X'
li t2,'O'
li t3,'d'

inGame:
	li t6 , 1 #this counter keeps track of the turn of the players if the counter is a pair number then 
	 	  #the X will play otherwise it's for the O to play
	li a7, ReadChar
	ecall
	
	beq a0,'q' , Exit
	beq a0 , t3, gameStatus
	bgt a0 , 0, gameActionCheck
	
	
	addi t6 ,t6,1
	
	
gameActionCheck:
	blt a0,8,gameAction
	j Exit  #wrong input 
	
gameAction:
	
			
copy_loop:
    lb t5, 0(s1)   # Load a character from originalString
    beq t4,9, copy_done  # If null terminator is reached, exit the loop

    # Check if this is the character at position 3
    li t4, a0 # The position to change
    beq t0, t3, change_character  # If it's the character at position 3, go to change_character

    # Copy the character to modifiedString
    sb t2, 0(a1)

    # Move to the next character
    addi a0, a0, 1
    addi a1, a1, 1
    addi t4, t4, 1
    j copy_loop
	
change_character:
    # Change the character at position 3 (0-based index)
    li t2, 'X'  # Change it to 'X'

    # Copy the modified character to modifiedString
    sb t2, 0(a1)

    # Move to the next character
    addi a0, a0, 1
    addi a1, a1, 1
    addi t0, t0, 1
    j copy_loop
    
    
copy_done:
    # Add a null terminator to the modifiedString
    li t2, 0
    sb t2, 0(a1)
	
isOdd:
	#check the counter to see if which player is playing

gameStatus:
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
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, s3
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, s4
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, s5
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	li a7, PrintString	
	mv a0, s6
	ecall
	li a7, PrintChar	
	mv a0,t0
	ecall
	j inGame
	
	
Exit:
	li a7,Exit
	ecall
