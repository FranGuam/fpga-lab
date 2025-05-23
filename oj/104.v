/*
SHA256核心压缩函数

# 题目描述
SHA256是SHA-2下细分出的一种密码散列函数算法，可以把消息或数据压缩成摘要。该函数将数据打乱混合，重新创建一个叫做散列值（或哈希值）的指纹。SHA256广泛用于文件完整性检查、数字签名，以及某云盘的秒上传、比特币挖矿等功能。
其中，SHA256中的一个核心为下面的映射（题图）：
    S0 = (A rr 2) xor (A rr 13) xor (A rr 22)
    t2 = S0 + Maj(A,B,C)
    S1 = (E rr 6) xor (E rr 11) xor (E rr 25)
    ch = (E and F) xor ((not E) and G)
    t1 = H + S1 + ch + Kt + Wt
    (A, B, C, D, E, F, G, H) = (t1+t2, A, B, C, D+t1, E, F, G)
其中
（1） 加法为32比特无符号加法，自然溢出，即结果为(A+B) mod 2^32。
（2） Maj(A,B,C)为投票函数，A、B、C三个输入中，如果对应比特中，有两个或三个1，则Maj(A,B,C)对应比特为1，否则为0。
    例如：
    A = 32’b10100001111000100100101110101010;
    B = 32’b00011000111110000110100001110010;
    C = 32’b01000111010010111010100011000110;
    Maj=32’b00000001111010100110100011100010;
（3） rr为循环右移，移出的低位放到该数的高位
请根据上述信息，补全代码，实现上述功能。（本题目不显示波形和电路图）
例如，输入为：
    Kt =dd98c76c
    Wt =2cfab1ef
    a_in=970e6947
    b_in=82eb1577
    c_in=a0a1bc71
    d_in=af2b3020
    e_in=371feebc
    f_in=4c38ed92
    g_in=7d72a3f4
    h_in=45c1d292
内部变量为：
    maj =82ab3d77
    s0 =965a3c7e
    s1 =a8adc25c
    t1 =457bfc19
    t2 =190579f5
    ch =4c78edd0
输出为：
    a_out=5e81760e
    b_out=970e6947
    c_out=82eb1577
    d_out=a0a1bc71
    e_out=f4a72c39
    f_out=371feebc
    g_out=4c38ed92
    h_out=7d72a3f4

# 输入格式
input [31:0] Kt, Wt
input [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in

# 输出格式
output [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
*/

// round compression function
module sha256_round (
    input [31:0] Kt, Wt,
    input [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
);
    wire [31:0] maj, s0, s1, t1, t2, ch;
    sha256_S0 s0m(a_in, s0);
    Maj majm(a_in, b_in, c_in, maj);
    assign t2 = s0 + maj;
    sha256_S1 s1m(e_in, s1);
    Ch chm(e_in, f_in, g_in, ch);
    assign t1 = h_in + s1 + ch + Kt + Wt;
    assign a_out = t1 + t2;
    assign b_out = a_in;
    assign c_out = b_in;
    assign d_out = c_in;
    assign e_out = d_in + t1;
    assign f_out = e_in;
    assign g_out = f_in;
    assign h_out = g_in;
endmodule

// S0(x)
module sha256_S0 (
    input wire [31:0] x,
    output wire [31:0] S0
);
    assign S0 = ({x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]});
endmodule

// S1(x)
module sha256_S1 (
    input wire [31:0] x,
    output wire [31:0] S1
    );
    assign S1 = ({x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]});
endmodule

// Ch(x,y,z)
module Ch (
    input wire [31:0] x, y, z,
    output wire [31:0] Ch
);
    assign Ch = ((x & y) ^ (~x & z));
endmodule

// Maj(x,y,z)
module Maj (
    input wire [31:0] x, y, z,
    output wire [31:0] Maj
);
    assign Maj = ((x & y) ^ (x & z) ^ (y & z));
endmodule