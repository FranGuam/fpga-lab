module task2_2 (sw, key3, key5, led);
input [7:7] sw;
input key3, key5;
output [7:0] led;

reg [5:0] history;
reg result;
assign led[7:2] = history;
assign led[0] = result;
wire clk, reset;
assign clk = key3;
assign reset = key5;

always @(posedge clk or posedge reset) begin
    result <= 0;
    if (reset) begin
        history <= 0;
    end
    else begin
        history = {history[4:0], sw[7]};
        if (history == 6'b101011) result <= 1;
    end
end

endmodule
