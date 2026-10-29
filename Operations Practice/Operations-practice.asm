.data
X_equals: .asciiz "X = "
Y_equals: .asciiz "Y = "
N_equals: .asciiz "n = "
operation: .asciiz "Choose logical operation (1: AND, 2: OR, 3: NOT, 4: SLL, 5: SRL) "
bitshift_amount: .asciiz "How many bit positions to shift: "
label_and: .asciiz "X&Y = "
label_or: .asciiz "X|Y = "
label_not: .asciiz "!X"
label_sll: .asciiz "X << n = "
label_srl: .asciiz "Y << n = "
newline: .asciiz "\n"

X:	.word 0
Y:	.word 0
R:	.word 0


.text
main: 
#get X
li $v0, 4 	#load print string X
la $a0, X_equals
syscall

li $v0, 5 	#read X
syscall
beq $v0, 0, Exit	#check if x = 0
sw $v0, X	#save value to x

#get Y
li $v0, 4 	#load print string Y
la $a0, Y_equals
syscall

li $v0, 5 	#read y
syscall
sw $v0, Y	#save value to y

#Choice of operation
li $v0, 4 	#load print string operation
la $a0, operation
syscall

li $v0, 5 	#read choice
syscall
move $s0, $v0

#load x and y
lw $t1, X
lw $t2, Y

beq $s0, 1, operation_and
beq $s0, 2, operation_or
beq $s0, 3, operation_not
beq $s0, 4, operation_sll
beq $s0, 5, operation_srl
j Exit

#operations
operation_and:
and $t3, $t1, $t2  #t3 = x&y
la $a0, label_and
j default_result

operation_or:
or $t3, $t1, $t2
la $a0, label_or
j default_result

operation_not:
nor $t3, $t1, $zero	#not x
la $a0, label_not
j result_not

operation_sll:
li $v0, 4	#prompt shift amount
la $a0, bitshift_amount
syscall

li $v0, 5	#get shift amount n
syscall
move $t0, $v0

sllv $t3, $t1, $t0 #shift and print result
la $a0, label_sll
j result_shift

operation_srl:
li $v0, 4	#prompt shift amount
la $a0, bitshift_amount
syscall

li $v0, 5	#get shift amount n
syscall
move $t0, $v0

srlv $t3, $t1, $t0 #shift and print result
la $a0, label_srl
j result_shift

#printing results
default_result:
sw $t3, R
move $s1, $a0

#Print X = 
li $v0, 4 	#load print string X
la $a0, X_equals
syscall
move $a0, $t1
jal print_binary

#Print Y = 
li $v0, 4 	#load print string Y
la $a0, Y_equals
syscall
move $a0, $t2
jal print_binary

#Print Result = 
li $v0, 4	
move $a0, $s1
syscall
move $a0, $t3
jal print_binary

li $v0, 4
la $a0, newline
syscall

j main

result_not:
sw $t3, R
move $s1, $a0

#Print X
li $v0, 4
la $a0, X_equals
syscall
move $a0, $t1
jal print_binary

#Print Result
li $v0, 4
move $a0, $s1
syscall
move $a0, $t3
jal print_binary

li $v0, 4
la $a0, newline
syscall

j main

result_shift:
sw $t3, R
move $s1, $a0

#Print X
li $v0, 4
la $a0, X_equals
syscall
move $a0, $t1
jal print_binary

#Print N
li $v0, 4
la $a0, N_equals
syscall

li $v0, 1
move $a0, $t0
syscall

li $v0, 4
la $a0, newline
syscall

#Print R
li $v0, 4
move $a0, $s1
syscall
move $a0, $t3
jal print_binary

li $v0, 4
la $a0, newline
syscall

j main

print_binary: 
move $t8, $a0
li $t9, 32

binary_loop:
srl $a0, $t8, 31

li $v0, 1
syscall

sll $t8, $t8, 1

subi $t9, $t9, 1
bgtz $t9, binary_loop

li $v0, 4
la $a0, newline
syscall

jr $ra

Exit: 
li $v0, 10
syscall
