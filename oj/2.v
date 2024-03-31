/*
XNOR 门

# 题目描述
同或(XNOR)门
同或门的逻辑特点是
- 当两个输入端一个为0，另一个为1时，输出为0
- 当两个输入端均为1或均为0时，输出为1

# 输入格式
输入为 a 和 b，均为 1-bit wire。

# 输出格式
输出out，为 a 和 b 进行同或运算的结果，位宽为 1。
*/

module Xnor( 
    input a, 
    input b, 
    output out
);
    assign out = a ~^ b;
endmodule