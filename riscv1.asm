.eqv PrintChar, 11
.eqv ReadChar, 12
.eqv PrintString, 4
.eqv Exit, 10

.data
Board: .word L1 L2 L3 L4 L5 L6 L7

L1: .string ":1ABCD:"
L2: .string ":2EFGH:"
L3: .string ":3IJKL:"
L4: .string ":4MNOP:"
L5: .string ":5QRST:"
L6: .string ":6UVXY:"
L7: .string ":7Z-_?:"


.text
la t0, Board
li t3 , 7
li t4 , 1
li t5 , 2
lw t1, 0(t0)
mul t6 , t3, t4
add t1, t1, t6
add t1, t1, t5 
lb t2, 0(t1)
mv a0, t2
li a7, PrintChar
ecall