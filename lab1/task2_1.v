module task2_1 (sw, key3, key5, led);
input [7:7] sw;
input key3, key5;
output [7:0] led;

reg [2:0] state;
reg result;
assign led[7:5] = state;
assign led[0] = result;
wire clk, reset;
assign clk = key3;
assign reset = key5;

always @(posedge clk or posedge reset) begin
    result <= 0;
    if (reset) begin
        state <= 0;
    end
    else begin
        case (state)
            0: if (sw[7] == 1) state <= 1;
            1: if (sw[7] == 0) state <= 2; else state <= 1;
            2: if (sw[7] == 1) state <= 3; else state <= 0;
            3: if (sw[7] == 0) state <= 4; else state <= 1;
            4: if (sw[7] == 1) state <= 5; else state <= 0;
            5:  if (sw[7] == 1) begin
                    state <= 1;
                    result <= 1;
                end
                else begin
                    state <= 4;
                end
        endcase
    end
end

endmodule
