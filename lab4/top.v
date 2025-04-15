module top (clock, key5, led);
input clock;
input key5;
output [7:0] led;

wire clk_out1;
wire clk_out2;
wire reset;
wire locked;
assign reset = key5;
assign led[7] = locked;

PLL pll (clk_out1, clk_out2, reset, locked, clock);

divider divider1 (clk_out1 && locked, reset, led[0]);
divider divider2 (clk_out2 && locked, reset, led[1]);

endmodule
