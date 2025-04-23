# 支持的 MIPS 指令

## 空闲指令

| 指令 | 格式 | 说明 |
| --- | --- | --- |
| nop | nop | 空闲指令，不执行任何操作 |

## 存储访问指令

| 指令 | OpCode | Funct | 格式 | 说明 |
| --- | --- | --- | --- | --- |
| lw | 0x23 | - | lw rt, offset(rs) | 从内存中读取一个字的数据，并存储到寄存器rt中 |
| sw | 0x2b | - | sw rt, offset(rs) | 将寄存器rt中的数据存储到内存中 |
| lui | 0x0f | - | lui rt, immediate | 将立即数immediate左移16位，并存储到寄存器rt中 |

## 算术运算指令

| 指令 | OpCode | Funct | 格式 | 说明 |
| --- | --- | --- | --- | --- |
| add | 0x00 | 0x20 | add rd, rs, rt | 将寄存器rs和rt中的数据相加，并存储到寄存器rd中 |
| addu | 0x00 | 0x21 | addu rd, rs, rt | 将寄存器rs和rt中的数据相加，并存储到寄存器rd中，不考虑溢出 |
| sub | 0x00 | 0x22 | sub rd, rs, rt | 将寄存器rs中的数据减去寄存器rt中的数据，并存储到寄存器rd中 |
| subu | 0x00 | 0x23 | subu rd, rs, rt | 将寄存器rs中的数据减去寄存器rt中的数据，并存储到寄存器rd中，不考虑溢出 |
| addi | 0x08 | - | addi rt, rs, immediate | 将寄存器rs中的数据加上立即数immediate，并存储到寄存器rt中 |
| addiu | 0x09 | - | addiu rt, rs, immediate | 将寄存器rs中的数据加上立即数immediate，并存储到寄存器rt中，不考虑溢出 |
| *mul* | 0x1c | 0x02 | mul rd, rs, rt | 将寄存器rs和rt中的数据相乘，并存储到寄存器rd中 |

## 逻辑运算指令

| 指令 | OpCode | Funct | 格式 | 说明 |
| --- | --- | --- | --- | --- |
| and | 0x00 | 0x24 | and rd, rs, rt | 将寄存器rs和rt中的数据进行按位与运算，并存储到寄存器rd中 |
| or | 0x00 | 0x25 | or rd, rs, rt | 将寄存器rs和rt中的数据进行按位或运算，并存储到寄存器rd中 |
| xor | 0x00 | 0x26 | xor rd, rs, rt | 将寄存器rs和rt中的数据进行按位异或运算，并存储到寄存器rd中 |
| nor | 0x00 | 0x27 | nor rd, rs, rt | 将寄存器rs和rt中的数据进行按位或运算，并存储到寄存器rd中，结果取反 |
| andi | 0x0c | - | andi rt, rs, immediate | 将寄存器rs中的数据与立即数immediate进行按位与运算，并存储到寄存器rt中 |
| *ori* | 0x0d | - | ori rt, rs, immediate | 将寄存器rs中的数据与立即数immediate进行按位或运算，并存储到寄存器rt中 |
| sll | 0x00 | 0x00 | sll rd, rt, sa | 将寄存器rt中的数据左移sa位，并存储到寄存器rd中 |
| srl | 0x00 | 0x02 | srl rd, rt, sa | 将寄存器rt中的数据右移sa位，并存储到寄存器rd中 |
| sra | 0x00 | 0x03 | sra rd, rt, sa | 将寄存器rt中的数据右移sa位，并存储到寄存器rd中，使用符号位填充空出的位 |
| slt | 0x00 | 0x2a | slt rd, rs, rt | 比较寄存器rs和rt中的数据，如果rs小于rt，则将1存储到寄存器rd中，否则将0存储到寄存器rd中 |
| sltu | 0x00 | 0x2b | sltu rd, rs, rt | 比较寄存器rs和rt中的数据，不考虑符号位，如果rs小于rt，则将1存储到寄存器rd中，否则将0存储到寄存器rd中 |
| slti | 0x0a | - | slti rt, rs, immediate | 比较寄存器rs和立即数immediate，如果rs小于immediate，则将1存储到寄存器rt中，否则将0存储到寄存器rt中 |
| sltiu | 0x0b | - | sltiu rt, rs, immediate | 比较寄存器rs和立即数immediate，不考虑符号位，如果rs小于immediate，则将1存储到寄存器rt中，否则将0存储到寄存器rt中 |

## 跳转指令

| 指令 | OpCode | Funct | 格式 | 说明 |
| --- | --- | --- | --- | --- |
| beq | 0x04 | - | beq rs, rt, offset | 如果寄存器rs和rt中的数据相等，则跳转到offset处执行 |
| *bne* | 0x05 | - | bne rs, rt, offset | 如果寄存器rs和rt中的数据不相等，则跳转到offset处执行 |
| *blez* | 0x06 | - | blez rs, offset | 如果寄存器rs中的数据小于等于0，则跳转到offset处执行 |
| *bgtz* | 0x07 | - | bgtz rs, offset | 如果寄存器rs中的数据大于0，则跳转到offset处执行 |
| *bltz* | 0x01 | - | bltz rs, offset | 如果寄存器rs中的数据小于0，则跳转到offset处执行 |
| j | 0x02 | - | j target | 无条件跳转到target处执行 |
| jal | 0x03 | - | jal target | 跳转到target处执行，并将返回地址存储到寄存器ra中 |
| jr | 0x00 | 0x08 | jr rs | 跳转到寄存器rs中的数据所指定的地址处执行 |
| *jalr* | 0x00 | 0x09 | jalr rd, rs | 跳转到寄存器rs中的数据所指定的地址处执行，并将返回地址存储到寄存器rd中 |
