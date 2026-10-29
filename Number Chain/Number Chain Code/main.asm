#1. Create has_move and find empty neighbor
#2. Scoring
#3. Print Winner

.globl main

.text
main:
    jal initial_board
    jal print_title

    li $s0, 1                   # player goes first

game:
    jal print_board             # shows the board (after a move, shows the change)
    move $a0, $s0
    jal showTurn                # "Your turn" or "Computer's turn"

    beq $s0, 2, game_over       # computer's turn: stop for now

    #player's move
    move $a0, $s0
    jal get_move                # $v0 = source index, $v1 = destination index
    move $a0, $v0               # source
    move $a1, $v1               # destination
    move $a2, $s0               # owner
    jal place_chain             # destination = source number + 1
    j switch_player

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
