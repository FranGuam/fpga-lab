/*
M序列

# 题目描述
n位的线性反馈移位寄存器（LFSR）可以产生强自相关性和低互相关性的序列，其序列长度为(2^n)-1。这种序列称之为m序列，广泛用在加密、加扰、同步、误码率测量等领域。
其中一个5位移位寄存器构成的M序列发生器如下图所示，他可以产生长度为31的一个伪随机序列。
其中clk为时钟信号，preset为低电平有效同步置位信号。当时钟上升沿到来时，若preset信号有效，将D触发器各输出置为“1”。

# 输入格式
clk: 1bit
preset: 1bit

# 输出格式
out: 1bit
*/

module lfsr (
    input clk,
    input preset,     
    output out
);
    reg [4:0] q;
    always @(posedge clk) begin
        if (~preset) begin
            q <= 5'b11111;
        end else begin
            q <= {q[3:0], q[4] ^ q[1]};
        end
    end
    assign out = q[4];
endmodule