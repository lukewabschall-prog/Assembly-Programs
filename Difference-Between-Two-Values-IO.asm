.data
string1: .asciiz "Enter x value "
string2: .asciiz "Enter y value "
string3: .asciiz "The difference between X and Y (X - Y) is "

X:	.word 0
Y:	.word 0
D:	.word 0

.text
main:
#Prompt and read x value
li $v0, 4
la $a0, string1 #print string 1
syscall

li $v0, 5 #read int
syscall 
move $t0, $v0

la $t1, X #load x
sw $t0, 0($t1) #save int to x

#Prompt and read x value
li $v0, 4 
la $a0, string2 #print string 2
syscall

li $v0, 5 #read int
syscall
move $t0, $v0

la $t1, Y #load y
sw $t0, 0($t1) #save int to y

#load x and y from memory to registers
la $t1, X #load x
lw $t2, 0($t1) #save x to t2

la $t1, Y #load y
lw $t3, 0($t1) #save y to t3

#String 3 print
li $v0, 4
la $a0, string3 #print string 3
syscall

#Calculate difference
sub $t4, $t2, $t3 #subtract x - y

#load int D
la $t1, D #load D
sw $t4, 0($t1) #save d to t4

#Print difference
li $v0, 1 
lw $a0, D #print d
syscall

#End
li $v0, 10
syscall