# lui $a0, 0x1001

# addi
addi $t0, $zero, 0x1234

# addiu
addiu $t1, $zero, -0x4321

# add
add $t2, $t0, $t1

# addu
addu $t3, $t0, $t1

# sub
sub $t4, $t0, $t1

# subu
subu $t5, $t1, $t0

# mul
mul $t6, $t0, $t1

# and
and $t7, $t0, $t1

# andi
andi $s0, $t1, 0xffff

# or
or $s1, $t0, $t1

# xor
xor $s2, $t0, $t1

# nor
nor $s3, $t0, $t1

# sll
sll $s4, $t0, 16

# srl
srl $s5, $t1, 4

# sra
sra $s6, $t1, 4

# slt
slt $s7, $t0, $t1

# sltu
sltu $t8, $t0, $t1

# slti
slti $t9, $t0, -1

# sltiu
sltiu $k0, $t0, -1

# lui
lui $k1, 0xabcd

# sw
addi $k1, $k1, 0x1234
sw $k1, 4($a0)

# lw
addiu $a0, $a0, 8
lw $v0, -4($a0)

# beq
BEQ:
beq $t0, $t1, JAL
beq $t2, $t3, JAL
nop

# jal
JAL:
jal JR

# j
J:
j JALR

# jr
JR:
jr $ra

# jalr
JALR:
la $a2, BNE
jalr $a1, $a2
j Extended_Cases

# bne
BNE:
bne $t2, $t3, BLEZ
bne $t0, $t1, BLEZ
nop

# blez
BLEZ:
blez $t0, BGTZ
blez $zero, BGTZ
nop

# bgtz
BGTZ:
bgtz $t1, BLTZ
bgtz $t0, BLTZ
nop

# bltz
BLTZ:
bltz $t0, ORI
bltz $t1, ORI
nop

# ori
ORI:
ori $t0, $t1, 0xffff

jr $a1

Extended_Cases:

# RAW hazard
addi $t0, $zero, 0x1234
nop
nop
add $t0, $t0, $t0
nop
add $t0, $t0, $t0
add $t0, $t0, $t0

# Load-use hazard
sw $t0, 0($a0)
lw $v1, 0($a0)
add $v1, $v1, $v1