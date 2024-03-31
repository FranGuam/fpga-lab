/*
D触发器

# 题目描述
D触发器是一种电路，它存储一个位并定期更新，通常在时钟信号的上升沿更新。
本题中你需要创建一个D触发器，实现在每个时钟的上升沿将d的值赋予q。

# 输入格式
clk: 1bit
d: 1bit

# 输出格式
q: 1bit
*/

module D_flip_flop(
    input clk,
    input d,
    output reg q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule