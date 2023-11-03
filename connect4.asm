.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
L1 : .string  ":.......:"
L2 : .string  ":.......:"
L3 : .string  ":.......:"
L4 : .string  ":.......:"
L5 : .string  ":.......:"
L6 : .string  ":.......:"

.text
li t0,'\n'
la s1,L1
la s2,L2
la s3,L3
la s4,L4
la s5,L5
la s6,L6

li t1,'X'
li t2,'O'
li t3,'d'

inGame:
	li a7, ReadChar
	ecall
	
	beq a0 , t3, gameStatus
	beq a0 , 1, gameAction
	
gameAction:
	beq a0 , 1

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
