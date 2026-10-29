#global methods
.globl initial_board
.globl clear_board
.globl getCell
.globl getNumber
.globl getOwner
.globl setCell
.globl place_chain


#allocate space for arrays
.data
board: .space 36
owner: .space 36

#board data
.text
initial_board:
	la $t0, board
	la $t1, owner
	li $t2, 0

clear_board:
	#iterate through board set board[i] and owner[i] to $zero
	bge $t2, 36, set_board
	#owner
	add $t3, $t0, $t2
	sb $zero, 0($t3)
	#board
	add $t3, $t1, $t2
	sb $zero, 0($t3)
	#counter
	addi $t2, $t2, 1
	j clear_board

set_board:
	#initial chain numbers
	li $t4, 1	# +player 1 owns
	li $t5, 2	# +player 2 owns
	li $t6, 3
#computer (2)
	#set initial computers chain (display board)
	sb $t4, 0($t0)
	sb $t5, 7($t0)
	sb $t6, 14($t0)
	#set initial computer chain (owner)
	sb $t5, 0($t1)
	sb $t5, 7($t1)
	sb $t5, 14($t1)
#player (1)
	#set initial players chain (display board)
	sb $t4, 35($t0)
	sb $t5, 28($t0)
	sb $t6, 21($t0)
	#set initial player chain (owner)
	sb $t4, 21($t1)
	sb $t4, 28($t1)
	sb $t4, 35($t1)
	#return to game 
	jr $ra
	
setCell:	#needs index ($a0), number ($a1), owner ($a2)
	#change cell in board	$a0 = index, $a1 = number
        la $v0, board
        add $v0, $v0, $a0
        sb $a1, 0($v0)
        
        #change cell in owner	$a0 = index, $a2 = owner
        la $v0, owner
        add $v0, $v0, $a0
        sb $a2, 0($v0)
        
        jr $ra
	
place_chain:    #needs source index ($a0), destination index ($a1), owner ($a2)
    #destination gets (number at source + 1), owned by the player
    la $t0, board
    add $t1, $t0, $a0
    lb $t2, 0($t1)          # number at source
    addi $t2, $t2, 1        # one higher
    add $t1, $t0, $a1
    sb $t2, 0($t1)          # board[destination] = number + 1
    la $t0, owner
    add $t1, $t0, $a1
    sb $a2, 0($t1)          # owner[destination] = player
    jr $ra

getCell:
	#index ($v0) = row ($a0) * 6 + col ($a1)
	mul $a0, $a0, 6
	add $v0, $a0, $a1
	jr $ra
	
getNumber:
	#add index to board[0]; returns $v0: number in chain
	la $v0, board
	add $v0, $v0, $a0
	lb $v0, 0($v0)
	jr $ra

getOwner: 
	#add index to owner[0]; return $v0: owner of cell
	la $v0, owner
	add $v0, $v0, $a0
	lb $v0, 0($v0)
	jr $ra
	

#find highest number in board
highestNumber:
        li   $v0, 0
        li   $t0, 0
        la   $t1, owner
        la   $t2, board
        
loop:
	#branch if full board has been checked
        bge  $t0, 36, highestNumber_done
        
        add  $t3, $t1, $t0
        lbu  $t4, 0($t3)
        bne  $t4, $a0, highestNumber_next      # not this player's cell
        add  $t3, $t2, $t0
        lbu  $t4, 0($t3)
        ble  $t4, $v0, highestNumber_next
        move $v0, $t4
        
highestNumber_next:
        addi $t0, $t0, 1
        j loop
        
highestNumber_done:
        jr   $ra
	
	
	
