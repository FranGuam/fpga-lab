module task1 (sw, key3, key5, sel, seg);
input [3:0] sw;
input key3, key5;
output [3:0] sel;
output [6:0] seg;

reg [3:0] count;
wire clk, reset;
assign clk = key3;
assign reset = key5;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
    end
    else begin
        count <= (count + 1) % 10;
    end
end

assign sel = sw[3:0];
BCD7 bcd27seg (count, seg);
endmodule
