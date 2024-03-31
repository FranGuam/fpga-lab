/*
2选1MUX

# 题目描述
二路选择器的逻辑特点是：
- 当选择器sel为0输出a的值
- 当选择器sel为1时，输出为b的值

# 输入格式
输入a,b,sel 都为1bit信号

# 输出格式
输出out 为1bit信号
你需要通过sel来控制out的结果
*/

module Mux(
    input sel,
    input a,
    input b,
    output out
);
    assign out = sel ? b : a;
endmodule