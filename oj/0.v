/*
输出0

# 题目描述
欢迎来到清华大学电子系VerilogOJ练习平台！
最开始的这道题目希望帮助您快速上手VerilogOJ——
请您构造一个输出常值0的电路。
要求使用assign语句对输出信号赋值。

# 输入格式
无输入信号

# 输出格式
输出单比特常值信号0
*/

module Zero(
    output out
);
    assign out = 1'b0;
endmodule