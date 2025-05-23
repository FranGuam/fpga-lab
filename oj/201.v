/*
D锁存器

# 题目描述
锁存器,是数字电路中的一种具有记忆功能的逻辑元件,只有在有锁存信号时输入的状态被保存到输出，直到下一个锁存信号。
本题中，你需要创建一个D锁存器，在使能信号ena为高电平时将输入保存到输出。

# 输入格式
d: 1bit
ena: 1bit

# 输出格式
q: 1bit
*/

module D_latch(
    input d, 
    input ena,
    output q
);
    reg q;
    always @(d, ena) begin
        if (ena) begin
            q <= d;
        end
    end
endmodule