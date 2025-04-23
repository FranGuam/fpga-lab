main_entry:

# Calculate device address offset
# lui $t0, 0x1001 # for debug use
lui $t0, 0x4000 # $t0 = 0x40000000

jal receive_entry

addi $a0, $v0, 0

jal send_entry

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
