#2. change values of board
#3. print changed board
#4. human and computer moves
#5. game loop and completion
.globl print_title
.globl print_board
.globl showTurn

.data
saved_ra:   .word 0
title:      .asciiz "Number Chain \nPlayer 1 = A  Player 2 = B \nPick one of your numbers n and place n+1 on an empty adjacent square\n Highest number when nobody can move wins.\n\n"
border:	    .asciiz "==================================="
header:     .asciiz "\n    0    1    2    3    4    5\n\n"
space:      .asciiz " "
spaces:     .asciiz "  "
emptyCell:  .asciiz "  .  "
newline:    .asciiz "\n"
player_turn: .asciiz "Your turn\n"
computer_turn: .asciiz "Computer's turn\n"
turn:       .asciiz "'s turn\n"
pass:       .asciiz " has no legal move and passes.\n"
place:      .asciiz " placed "
at:         .asciiz " at ("
comma:      .asciiz ","
close_newline:    .asciiz ")\n"
finish:     .asciiz "\n=== GAME OVER ===\n"
highest_1:    .asciiz "Player 1 (A) highest number: "
highest_2:    .asciiz "Player 2 (B) highest number: "
winner_1:     .asciiz "\nPLAYER 1 (A) WINS!\n"
winner_2:     .asciiz "\nPLAYER 2 (B) WINS!\n"
draw:     .asciiz "\nIt's a draw!\n"

.text

print_title:
	li $v0, 4
	la $a0, title
	syscall
	jr $ra
	
showTurn:
        beq $a0, 1, showTurn_player
        la $a0, computer_turn
        j print_turn
        
showTurn_player:
        la $a0, player_turn
        
print_turn:
        li $v0, 4
        syscall
        jr $ra
	
print_board:
	sw $ra, saved_ra
	
        #print header
        la   $a0, header
        li   $v0, 4
        syscall
        
        #initialize row counter
	li $s0, 0

print_rowNum:
	#if end row print newline
	bge $s0, 6, done
	
	#print current row number
	move $a0, $s0
	li $v0, 1
	syscall
	
	#print spaces between
	la $a0, spaces
	li $v0, 4
	syscall
	
	#set column number back to zero
	li $s1, 0
	
fill_board:
	bge $s1, 6, endrow
	
	#get index $s0 = row, $s1 = column, $s2 = index & number, $s3 = owner
	move $a0, $s0
	move $a1, $s1
	jal getCell
	
	#get owner
	move $s2, $v0	#index ($s2) = result of getCell ($v0)
        move $a0, $s2	
        jal getOwner
        
        #get number
        move $s3, $v0	#owner ($s3) = result of getOwner ($v0)
        move $a0, $s2
        jal getNumber
        move $s2, $v0	#index ($2) = number ($v0)
        beqz $s2, print_owner_none	#if cell is empty
        
	#print number & owner @ index
	bge $s2, 10, print_cell
	li $v0, 4
	la $a0, space	#if number is lower than 10 print a space prior for alignment
	syscall
	
print_cell:
	
	move $a0, $s2	#print number
	li $v0, 1
	syscall

	li $a0, 'A'	#default print A
        bne $s3, 2, print_letter	#if not A jump and print B else load A and print
        li $a0, 'B'
        
print_letter:
	#print letter
        li $v0, 11
        syscall
        
        #print spaces
        la $a0, spaces
        li $v0, 4
        syscall
        
        #jump to next cell
        j next

print_owner_none:
	#print no owner of cell
	la $a0, emptyCell
	li $v0, 4
	syscall
	
next:	
	#increase colummn counter and return to fill columns
	addi $s1, $s1, 1
	j fill_board
	
endrow:
	#print \n and row num +
        la $a0, newline
        li $v0, 4
        syscall
        la $a0, newline
        li $v0, 4
        syscall
        addi $s0, $s0, 1
        j    print_rowNum

done:
	lw $ra, saved_ra
	jr $ra