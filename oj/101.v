/*
3-8译码器

# 题目描述
该模块将3bit输入转为8bit输出
输入000对应输出为0000_0001
输入011对应输出为0000_1000
输入111对应输出为1000_0000

# 输入格式
x: 3bit

# 输出格式
y: 8bit
*/

module decoder(
    input [2:0] x,
    output reg [7:0] y
);
    always @(*)
    begin
        case(x)
            3'b000: y = 8'b0000_0001;
            3'b001: y = 8'b0000_0010;
            3'b010: y = 8'b0000_0100;
            3'b011: y = 8'b0000_1000;
            3'b100: y = 8'b0001_0000;
            3'b101: y = 8'b0010_0000;
            3'b110: y = 8'b0100_0000;
            3'b111: y = 8'b1000_0000;
        endcase
    end
endmodule