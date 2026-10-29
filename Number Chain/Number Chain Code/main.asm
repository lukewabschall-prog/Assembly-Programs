.globl main

# $s0 = whose turn (1 = you, 2 = computer). Only main touches $s0.

.text
main:
    	jal initial_board
    	jal print_title

	#generate random starting player 
	li $v0, 42
	li $a0, 0
	li $a1, 2
	syscall
	
	addi $a0, $a0, 1	#change range from [0,1] to [1,2]
    	move $s0, $a0	#save which player goes first

game:
    	#game ends when neither player can move
    	li $a0, 1
    	jal has_move
    	bnez $v0, turn_check        # player 1 can still move
    	li $a0, 2
    	jal has_move
    	beqz $v0, game_over         # neither player can move

turn_check:
    	#current player stuck: skip their turn
    	move $a0, $s0
    	jal has_move
    	beqz $v0, switch_player

    	jal print_board
    	move $a0, $s0
    	jal showTurn

    	beq $s0, 2, computer_move

player_move:
    	move $a0, $s0
    	jal get_move                # $v0 = source index, $v1 = destination index
    	j make_move

computer_move:
    	move $a0, $s0
    	jal computer_decision       # $v0 = source index, $v1 = destination index

make_move:
    	move $a0, $v0               # source
    	move $a1, $v1               # destination
    	move $a2, $s0               # owner
    	jal place_chain

switch_player:
    	beq $s0, 1, to_player2
    	li $s0, 1
    	j game

to_player2:
    	li $s0, 2
    	j game

game_over:
    	jal print_board             # final board
	
    	li $a0, 1
    	jal highestNumber
    	move $s1, $v0               # player 1's highest number
    	li $a0, 2
    	jal highestNumber
    	move $s2, $v0               # player 2's highest number

    	li $a0, 0                   # 0 = draw
    	bgt $s1, $s2, player1_wins
    	blt $s1, $s2, player2_wins
    	j show_winner

player1_wins:
    	li $a0, 1
    	j show_winner

player2_wins:
    	li $a0, 2

show_winner:
    	jal print_winner
    	li $v0, 10                  # exit
    	syscall
