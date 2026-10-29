.globl computer_decision
.globl find_empty_neighbor
.globl has_move

.data
saved_ra_fen: .word 0
saved_ra_ai:  .word 0
saved_ra_has: .word 0

.text

# find_empty_neighbor($a0 = cell index)
#   -> $v0 = index of the first empty square touching that cell (8 directions),
#      or -1 if every neighbour is taken or off the board.
# Uses $t0-$t5 only:  $t0 = row  $t1 = col  $t2 = dr  $t3 = dc  $t4 = candidate index
find_empty_neighbor:
    	sw $ra, saved_ra_fen
    	li $t5, 6
    	div $a0, $t5
    	mflo $t0                    # row of the cell
    	mfhi $t1                    # column of the cell

    	li $t2, -1                  # dr goes -1, 0, 1
fen_dr:
    	bgt $t2, 1, fen_none
    	li $t3, -1                  # dc goes -1, 0, 1
fen_dc:
    	bgt $t3, 1, fen_next_dr
    	bnez $t2, fen_try
    	beqz $t3, fen_next_dc       # dr = 0 and dc = 0 is the cell itself, skip it

fen_try:
    	add $a0, $t0, $t2           # neighbour row
    	add $a1, $t1, $t3           # neighbour column
    	bltz $a0, fen_next_dc       # off the board
    	bgt  $a0, 5, fen_next_dc
    	bltz $a1, fen_next_dc
    	bgt  $a1, 5, fen_next_dc
    	jal getCell
    	move $t4, $v0               # neighbour index
    	move $a0, $t4
    	jal getNumber
    	bnez $v0, fen_next_dc       # occupied, try the next direction
    	move $v0, $t4               # found an empty one
    	j fen_return

fen_next_dc:
    	addi $t3, $t3, 1
    	j fen_dc
fen_next_dr:
    	addi $t2, $t2, 1
    	j fen_dr
fen_none:
    	li $v0, -1
fen_return:
    	lw $ra, saved_ra_fen
    	jr $ra

# computer_decision($a0 = player)
#   -> $v0 = source index, $v1 = destination index   ($v0 = -1 if it cannot move)
# Greedy: picks the move that places the highest number.
# Uses $s1-$s6 (main only keeps $s0), and calls find_empty_neighbor, which uses $t.
#   $s1 = cell being examined   $s2 = player        $s3 = best number so far
#   $s4 = best source           $s5 = best destination
#   $s6 = number this cell would place
computer_decision:
    	sw $ra, saved_ra_ai
    	move $s2, $a0
    	li $s1, 0
    	li $s3, 0
    	li $s4, -1
    	li $s5, -1

ai_loop:
    	bge $s1, 36, ai_done
    	move $a0, $s1
    	jal getOwner
    	bne $v0, $s2, ai_next       # not the computer's cell
    	move $a0, $s1
    	jal getNumber
    	addi $s6, $v0, 1            # number it would place
    	ble  $s6, $s3, ai_next      # can't beat the best so far
    	move $a0, $s1
    	jal find_empty_neighbor
    	bltz $v0, ai_next           # blocked in
    	move $s3, $s6               # new best
    	move $s4, $s1
    	move $s5, $v0
ai_next:
    	addi $s1, $s1, 1
    	j ai_loop

ai_done:
    	move $v0, $s4
    	move $v1, $s5
    	lw $ra, saved_ra_ai
    	jr $ra

# has_move($a0 = player)  ->  $v0 = 1 if the player has any legal move, else 0
# Uses $s1 = cell being examined, $s2 = player; calls find_empty_neighbor ($t0-$t5).
has_move:
    	sw $ra, saved_ra_has
    	move $s2, $a0
    	li $s1, 0

has_move_loop:
    	bge $s1, 36, has_move_none
    	move $a0, $s1
    	jal getOwner
    	bne $v0, $s2, has_move_next     # not this player's cell
    	move $a0, $s1
    	jal find_empty_neighbor
    	bgez $v0, has_move_found        # this cell can chain somewhere
has_move_next:
    	addi $s1, $s1, 1
    	j has_move_loop

has_move_found:
    	li $v0, 1
    	j has_move_return

has_move_none:
    	li $v0, 0

has_move_return:
    	lw $ra, saved_ra_has
    	jr $ra
