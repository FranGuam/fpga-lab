/*
全加器

# 题目描述
创建完整的加法器。全加法器将三位相加(包括进位)，产生和和进位。

# 输入格式
a: 1bit
b: 1bit
cin: 1bit

# 输出格式
sum: 1bit
cout: 1bit
*/

module full_adder(
    input a, b, cin,
    output cout, sum
);
    assign {cout, sum} = a + b + cin;
endmodule
