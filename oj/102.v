/*
将二进制码转换为格雷码

# 题目描述
格雷码特点是任意两个相邻的码字间有且只有一位二进制数不同。
二进制码转换成格雷码的法则：保留二进制码的最高位作为格雷码的最高位，而格雷码的次高位为二进制码的最高位与次高位相异或，格雷码的其余各位与格雷码的次高位的求法相类似。
比如：二进制数8‘b0000_0000的格雷码还是8'b0000_0000，二进制数8‘b0101_1100的格雷码是8'b0111_0010。

# 输入格式
输入为 in，为 8-bit wire。

# 输出格式
输出为 binary2gray，为 in 从二进制码转为格雷码的结果，位宽为 8。
*/

module B2G( 
    input [7:0] in, 
    output [7:0] binary2gray
);
    assign binary2gray[7] = in[7];
    assign binary2gray[6] = in[7] ^ in[6];
    assign binary2gray[5] = in[6] ^ in[5];
    assign binary2gray[4] = in[5] ^ in[4];
    assign binary2gray[3] = in[4] ^ in[3];
    assign binary2gray[2] = in[3] ^ in[2];
    assign binary2gray[1] = in[2] ^ in[1];
    assign binary2gray[0] = in[1] ^ in[0];
endmodule
