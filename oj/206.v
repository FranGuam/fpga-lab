/*
滑动平均滤波器

# 题目描述

# 输入格式
clk: 1bit
reset: 1bit
din[4:0]: 5bit

# 输出格式
dout[7:0]: 8bit
*/

module maf(
    input clk,
    input reset,
    input [4:0] din,
    output [7:0] dout
);
    // 补充说明，数学上可以证明，如果内部累加器的位宽大于等于8bit，则累加器溢出不影响结果的正确性
    reg [4:0] z1;
    reg [4:0] z2;
    reg [4:0] z3;
    reg [4:0] z4;
    reg [4:0] z5;
    reg [4:0] z6;
    reg [7:0] dout;
    always @(posedge clk) begin
        if (reset) begin
            dout <= 8'b0;
            z1 <= 5'b0;
            z2 <= 5'b0;
            z3 <= 5'b0;
            z4 <= 5'b0;
            z5 <= 5'b0;
            z6 <= 5'b0;
        end else begin
            dout <= dout + z1 - z6;
            z6 <= z5;
            z5 <= z4;
            z4 <= z3;
            z3 <= z2;
            z2 <= z1;
            z1 <= din;
        end
    end
endmodule