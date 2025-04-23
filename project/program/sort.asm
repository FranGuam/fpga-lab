.data
.word 5
.word 5, 1, 3, 2, 4
.text
# lui $a0, 0x1001

main_entry:
lw $s0, 0($a0) # $s0 = N
sll $s0, $s0, 2
add $s0, $s0, $a0

# for (i = 1; i != N; i++)
addi $t0, $a0, 4 # $t0: i in address
main_loop0:

lw $t2, 0($s0) # $t2: smallest number
addi $t3, $s0, 0 # $t3: corresponding address

# for (j = N; j != i; j--)
addi $t1, $s0, 0 # $t1: j in address
main_loop1:
lw $t4, 0($t1)
# if ($t4 < $t2)
blt $t2, $t4, main_branch1
addi $t2, $t4, 0
addi $t3, $t1, 0
main_branch1:
addi $t1, $t1, -4
bne $t1, $t0, main_loop1

lw $t4, 0($t0)
# if ($t2 < $t4)
blt $t4, $t2, main_branch2
sw $t2, 0($t0)
sw $t4, 0($t3)

main_branch2:
addi $t0, $t0, 4
bne $t0, $s0, main_loop0
