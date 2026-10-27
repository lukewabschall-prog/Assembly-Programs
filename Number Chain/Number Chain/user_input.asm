.globl getSource

.data
source_row: .asciiz "Source (Row): "
source_column: .asciiz "Source (Column): "
destination_row: .asciiz "Destination (Row): "
destination_column: .asciiz "Destination (Column): "
invalid_move:  .asciiz "Invalid move\n"

.text

getSource:
	li $v0, 4	#prompt source row
	la $a0, source_row
	syscall
	
	li $v0, 5	#read source row
	syscall
	
	move $s0, $v0	#save source row
	
	li $v0, 4	#prompt source column
	la $a0, coloumn_row
	syscall
	
	li $v0, 5	#read source row
	syscall
	
	move $s1, $v0	#save source column

validateSource:
	#source row or column less than accepted value
	blt, $s0, 0, invalid
	blt, $s0, 0, invalid
	
	#source row or column greater than accepted value
	bgt $s0, 5, invalid
	bgt $s1, 5, invalid
	
valid:
	move $a0, $s0
	move $a1, $s1
	j getDesination

invalid:
	li $v0, 4
	la $a0, invalid_move
	syscall
	
	j game

getDesination:
	li $v0, 4	#prompt desination row
	la $a0, destination_row
	syscall
	
	li $v0, 5	#read destination row
	syscall
	
	move $s3, $v0	#save destination row
	
	li $v0, 4	#prompt destination row
	la $a0, destination_column
	syscall	
	
	li $v0, 5	#read destination column
	syscall
	
	move $s4, $v0	#save destintaion column

validateDestination:
	#s1 = sr, s2 = sc, s3 = dr, s4 = dc
	move $a0, $s3
	move $a1, $s4
	jal getCell	#provide destination column and row, get index
	
	move $a0, $v0
	jal getOwner
	
	jal getNumber
	

	beqz , invalid
	jal switchPlayer
	j game

