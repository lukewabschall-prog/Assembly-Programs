.globl get_move

.data
saved_ra_input: .word 0
source_row: .asciiz "Source (Row): "
source_column: .asciiz "Source (Column): "
destination_row: .asciiz "Destination (Row): "
destination_column: .asciiz "Destination (Column): "
invalid_move:  .asciiz "Invalid move\n"

.text

# get_move($a0 = player)  ->  $v0 = source index, $v1 = destination index
# Asks again until the move is legal.
# Uses only $t registers, so main's $s0 is untouched. The helpers it calls
# (getCell, getOwner, getNumber) only change $v0 and $a0, so $t values survive.
#   $t0 = player          $t1 = source row     $t2 = source column
#   $t3 = destination row $t4 = destination column
#   $t5 = source index    $t6 = destination index
#   $t7, $t8, $t9 = scratch
get_move:
    sw $ra, saved_ra_input      # we call other functions, so keep our return address
    move $t0, $a0               # player

move_prompt:                    # <- every bad move comes back here
    li $v0, 4                   #prompt source row
    la $a0, source_row
    syscall

    li $v0, 5                   #read source row
    syscall
    move $t1, $v0

    li $v0, 4                   #prompt source column
    la $a0, source_column
    syscall

    li $v0, 5                   #read source column
    syscall
    move $t2, $v0

validateSource:
    #source row or column outside 0-5
    bltz $t1, bad_move
    bgt  $t1, 5, bad_move
    bltz $t2, bad_move
    bgt  $t2, 5, bad_move

    #source must be one of the player's own numbers
    move $a0, $t1
    move $a1, $t2
    jal getCell
    move $t5, $v0               # source index
    move $a0, $t5
    jal getOwner
    bne  $v0, $t0, bad_move

getDestination:
    li $v0, 4                   #prompt destination row
    la $a0, destination_row
    syscall

    li $v0, 5                   #read destination row
    syscall
    move $t3, $v0

    li $v0, 4                   #prompt destination column
    la $a0, destination_column
    syscall

    li $v0, 5                   #read destination column
    syscall
    move $t4, $v0

validateDestination:
    #destination row or column outside 0-5
    bltz $t3, bad_move
    bgt  $t3, 5, bad_move
    bltz $t4, bad_move
    bgt  $t4, 5, bad_move

    #destination must be empty
    move $a0, $t3
    move $a1, $t4
    jal getCell
    move $t6, $v0               # destination index
    move $a0, $t6
    jal getNumber
    bnez $v0, bad_move          # a number is already there

    #destination must touch the source (8 directions, not the same square)
    sub  $t7, $t3, $t1          # destination row - source row
    abs  $t7, $t7
    bgt  $t7, 1, bad_move       # more than 1 row away
    sub  $t8, $t4, $t2          # destination column - source column
    abs  $t8, $t8
    bgt  $t8, 1, bad_move       # more than 1 column away
    or   $t9, $t7, $t8
    beqz $t9, bad_move          # 0 rows and 0 columns away = same square

    #legal move: hand both indexes back
    move $v0, $t5
    move $v1, $t6
    lw   $ra, saved_ra_input
    jr   $ra

bad_move:
    li $v0, 4
    la $a0, invalid_move
    syscall
    j move_prompt
