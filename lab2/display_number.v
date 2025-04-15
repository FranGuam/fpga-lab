module display_number (clk, num, dpn, sel, seg, dp);
input clk;
input [13:0] num;
input [1:0] dpn;
output [3:0] sel;
output [6:0] seg;
output dp;

reg [1:0] index;
reg [3:0] sel;
reg [16:0] count;
reg [3:0] digit;
reg dp;

BCD7 bcd27seg (digit, seg);

always @(posedge clk) begin
    sel <= 1 << index;
    dp <= (index == dpn);
    case (index)
        0: digit <= num / 1000 % 10;
        1: digit <= num / 100 % 10;
        2: digit <= num / 10 % 10;
        3: digit <= num % 10;
    endcase
    // Refreshes every 1ms
    if (count == 100000) begin
        count <= 0;
        if (index == 3) index <= 0;
        else index <= index + 1;
    end
    else count <= count + 1;
end

endmodule
