/*
“1”的数目

# 题目描述
计数输入向量的二进制表示中“1”的数目。
比如输入为3‘b000，输出为2‘b00；3‘b011，输出为2‘b10；

# 输入格式
in: 3bit

# 输出格式
out: 2bit
*/

module population_count( 
    input [2:0] in, 
    output [1:0] out
);
    assign out = in[0] + in[1] + in[2];
endmodule