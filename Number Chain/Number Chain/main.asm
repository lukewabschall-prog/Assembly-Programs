.globl main

.text
main:
	jal initial_board
	jal print_title
	
	li $s0, 1	#player goes first
	
game:	
	#1. print board
	#2. print player turn
	#3. change cell
	beq $s0, 2, game_over	#if computer turn game over for now
	
	jal print_board
	move $a0, $s0
	jal showTurn
	
	#Make move
	beq $s0, 2, computer_move
	move $a0, $s0
	jal player_move
	j move
	
	
computer_move:
	move $a0, $s0
	jal computer_decision

player_move:
	#get source and destination
	move $a0, $s0
	jal get_source
	

move:
	move $a0, $s0	#owner
	move $a1, $s1	#index
	jal setCell
	j switchPlayer
	
computer_decision:
	

switch_player:
        beq $s0, 1, to_player2
        li $s0, 1
      	j game
        
to_player2:
        li $s0, 2
      	j game
        
game_over:
	#end program
	li $v0, 10
	syscall

