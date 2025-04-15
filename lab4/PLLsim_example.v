`timescale 1ns / 1ps
module test_pll();

parameter clk_period_100M = 10; // f=100MHz <=> T=10ns
	
wire clk_out1;
wire clk_out2;
reg reset;
wire locked;
reg clk_in1;

PLL pll(clk_out1, clk_out2, reset, locked, clk_in1);

initial begin
	reset <= 1;
	clk_in1 <= 1;
	#(clk_period_100M/2) reset <= 0;
end

always #(clk_period_100M/2) clk_in1 <= ~clk_in1;
		
endmodule