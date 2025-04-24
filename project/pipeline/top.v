module top(
    input             clock,
    input             key5,
    output [4 - 1: 0] sel,
    output [7 - 1: 0] seg,
    output            dp,
    input             rx,
    output            tx
);

    parameter CLK_FREQ = 100000000;

    wire clk;
    wire locked;

    assign clk = clock;
    assign locked = 1'b1;

    // clk_wiz_0 clkwiz(
    //     .clk_out1 (clk    ),
    //     .reset    (key5   ),
    //     .locked   (locked ),
    //     .clk_in1  (clock  )
    // );

    wire             Device_Read;
    wire             Device_Write;
    wire [32 - 1: 0] MemBus_Address;
    wire [32 - 1: 0] Device_Read_Data;
    wire [32 - 1: 0] MemBus_Write_Data;

    CPU cpu1(
        .reset             (key5 || !locked   ),
        .clk               (clk               ),
        .Device_Read       (Device_Read       ),
        .Device_Write      (Device_Write      ),
        .MemBus_Address    (MemBus_Address    ),
        .Device_Read_Data  (Device_Read_Data  ),
        .MemBus_Write_Data (MemBus_Write_Data )
    );

    Device #(
        .CLK_FREQ (CLK_FREQ)
    ) device1 (
        .reset      (key5 || !locked   ),
        .clk        (clk               ),
        .Read       (Device_Read       ),
        .Write      (Device_Write      ),
        .Address    (MemBus_Address    ),
        .Read_data  (Device_Read_Data  ),
        .Write_data (MemBus_Write_Data ),
        .sel        (sel               ),
        .seg        (seg               ),
        .dp         (dp                ),
        .rx         (rx                ),
        .tx         (tx                )
    );

endmodule
