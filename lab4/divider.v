module divider # (parameter N = 100000000) (clock, reset, clk_out);
input clock;
input reset;
output reg clk_out;

reg [31:0] count;

always @(posedge clock) begin
    if (reset) begin
        count <= 0;
        clk_out <= 0;
    end
    else begin
        if (count == N-1) count <= 0;
        else count <= count + 1;
        clk_out <= count < N/2;
    end
end

endmodule
