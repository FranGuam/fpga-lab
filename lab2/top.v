module top (clock, key3, key5, sel, seg, dp, led);
input clock;
input key3, key5;
output [3:0] sel;
output [6:0] seg;
output dp;
output [7:0] led;

reg [1:0] state;
reg [13:0] num;
reg [13:0] count;

assign led[0] = (state == 1);

display_number d (clock, (state == 0)? 0 : num, 2, sel, seg, dp);

always @(posedge clock) begin
    if (key5) begin
        count <= 0;
        num <= 0;
        state <= 0;
    end
    else if (state == 0) begin
        if (num == 10000) begin
            state <= 1;
            num <= 0;
        end
    end
    else if (state == 1) begin
        if (key3 || num == 9999) begin
            state <= 2;
        end
    end
    // Refreshes every 0.1ms
    if (count == 10000) begin
        count <= 0;
        if (state < 2) num <= num + 1;
    end
    else count <= count + 1;
end

endmodule
