main_entry:
#### Receive ####
# Calculate device address offset
lui $t0, 0x4000 # $t0 = 0x40000000

# Receive N
jal receive_entry
sw $v0, 0($a0)
addi $s0, $v0, 0
sll $s0, $s0, 2
add $s0, $s0, $a0

# for (i = 0; i != N; i++)
addi $s1, $a0, 0 # $s1: i in address

main_loop3:
jal receive_entry
sw $v0, 4($s1)

addi $s1, $s1, 4
bne $s1, $s0, main_loop3

#### Sort ####
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

#### Send ####
# Calculate device address offset
lui $t0, 0x4000 # $t0 = 0x40000000

addi $a1, $zero, 250
addi $s2, $a0, 0
# for (i = 0; i != N; i++)
addi $s1, $s2, 0 # $s1: i in address

main_loop4:
lw $a0, 4($s1)
jal send_entry
jal display_entry

addi $s1, $s1, 4
bne $s1, $s0, main_loop4

addi $a0, $s2, 0
j main_entry # Endless loop

receive_entry:
# Wait for a incoming message
receive_loop0:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0008
beq $t1, $zero, receive_loop0

# Read the message
lw $t2, 0x001c($t0)
addi $v0, $t2, 0

receive_loop1:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0008
beq $t1, $zero, receive_loop1

lw $t2, 0x001c($t0)
sll $t2, $t2, 8
or $v0, $v0, $t2

receive_loop2:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0008
beq $t1, $zero, receive_loop2

lw $t2, 0x001c($t0)
sll $t2, $t2, 16
or $v0, $v0, $t2

receive_loop3:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0008
beq $t1, $zero, receive_loop3

lw $t2, 0x001c($t0)
sll $t2, $t2, 24
or $v0, $v0, $t2

receive_return: jr $ra

send_entry:
# Send the message
srl $t2, $a0, 24
sw $t2, 0x0018($t0)

# Wait for the message to be sent
send_loop0:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0004
beq $t1, $zero, send_loop0

srl $t2, $a0, 16
sw $t2, 0x0018($t0)

send_loop1:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0004
beq $t1, $zero, send_loop1

srl $t2, $a0, 8
sw $t2, 0x0018($t0)

send_loop2:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0004
beq $t1, $zero, send_loop2

srl $t2, $a0, 0
sw $t2, 0x0018($t0)

send_loop3:
lw $t1, 0x0020($t0)
andi $t1, $t1, 0x0004
beq $t1, $zero, send_loop3

send_return: jr $ra

# Function display()
display_entry:
addi $t9 $ra 0

# Map hex value to 7-segment display
addi $t5, $a0, 0

andi $a0, $t5, 0xf000
srl $a0, $a0, 12
jal map_entry
addi $t1, $v0, 0x0100

andi $a0, $t5, 0x0f00
srl $a0, $a0, 8
jal map_entry
addi $t2, $v0, 0x0200

andi $a0, $t5, 0x00f0
srl $a0, $a0, 4
jal map_entry
addi $t3, $v0, 0x0400

andi $a0, $t5, 0x000f
jal map_entry
addi $t4, $v0, 0x0800

# Calculate device address offset
lui $t0, 0x4000 # $t0 = 0x40000000

# Set the 1ms count limit
addi $t5, $zero, 25000 # Given CLK_FREQ = 50 MHz

# Loop for $s0 times
addi $t6, $zero, 0
display_loop0:

sw $t1, 0x0010($t0)
addi $t7, $zero, 0
display_loop1:
addi $t7, $t7, 1
bne $t7, $t5, display_loop1

sw $t2, 0x0010($t0)
addi $t7, $zero, 0
display_loop2:
addi $t7, $t7, 1
bne $t7, $t5, display_loop2

sw $t3, 0x0010($t0)
addi $t7, $zero, 0
display_loop3:
addi $t7, $t7, 1
bne $t7, $t5, display_loop3

sw $t4, 0x0010($t0)
addi $t7, $zero, 0
display_loop4:
addi $t7, $t7, 1
bne $t7, $t5, display_loop4

addi $t6, $t6, 1
bne $t6, $a1, display_loop0

display_return: jr $t9

# Function map()
map_entry:
addi $t0, $zero, 0
addi $v0, $zero, 0x3f
beq $a0, $t0, map_return
addi $t0, $zero, 1
addi $v0, $zero, 0x06
beq $a0, $t0, map_return
addi $t0, $zero, 2
addi $v0, $zero, 0x5b
beq $a0, $t0, map_return
addi $t0, $zero, 3
addi $v0, $zero, 0x4f
beq $a0, $t0, map_return
addi $t0, $zero, 4
addi $v0, $zero, 0x66
beq $a0, $t0, map_return
addi $t0, $zero, 5
addi $v0, $zero, 0x6d
beq $a0, $t0, map_return
addi $t0, $zero, 6
addi $v0, $zero, 0x7d
beq $a0, $t0, map_return
addi $t0, $zero, 7
addi $v0, $zero, 0x07
beq $a0, $t0, map_return
addi $t0, $zero, 8
addi $v0, $zero, 0x7f
beq $a0, $t0, map_return
addi $t0, $zero, 9
addi $v0, $zero, 0x6f
beq $a0, $t0, map_return
addi $t0, $zero, 10
addi $v0, $zero, 0x77
beq $a0, $t0, map_return
addi $t0, $zero, 11
addi $v0, $zero, 0x7c
beq $a0, $t0, map_return
addi $t0, $zero, 12
addi $v0, $zero, 0x39
beq $a0, $t0, map_return
addi $t0, $zero, 13
addi $v0, $zero, 0x5e
beq $a0, $t0, map_return
addi $t0, $zero, 14
addi $v0, $zero, 0x79
beq $a0, $t0, map_return
addi $t0, $zero, 15
addi $v0, $zero, 0x71
map_return: jr $ra

