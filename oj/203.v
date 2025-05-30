/*
十进制计数器

# 题目描述
构建一个计数从0到9（包括0和9）的十进制计数器，周期为 10。
同步的复位信号将计数器复位为0。（当reset信号为active的时候，寄存器在下一个时钟沿到来之后被复位。）

# 输入格式
clk: 1bit
reset: 1bit

# 输出格式
q: 4bit
*/

module decade_counter(
    input clk,
    input reset,
    output [3:0] q
);
    reg [3:0] q;
    always @(posedge clk) begin
        if (reset) begin
            q <= 4'b0000;
        end else begin
            if (q == 4'b1001) begin
                q <= 4'b0000;
            end else begin
                q <= q + 1;
            end
        end
    end
endmodule