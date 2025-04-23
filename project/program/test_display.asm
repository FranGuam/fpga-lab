main_entry:
# Display each set of numbers for 1 sec
addi $a1, $zero, 250

# Call 1
addi $a0, $zero, 0x01ef
jal display_entry

# Call 2
addi $a0, $zero, 0x23cd
jal display_entry

# Call 3
addi $a0, $zero, 0x45ab
jal display_entry

# Call 4
addi $a0, $zero, 0x6789
jal display_entry

j main_entry # Endless loop

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
# lui $t0, 0x1001 # for debug use
lui $t0, 0x4000 # $t0 = 0x40000000

# Set the 1ms count limit
addi $t5, $zero, 25000 # Given CLK_FREQ = 50 MHz

# Loop for $a1 times
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
