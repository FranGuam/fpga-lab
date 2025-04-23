module UART #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 100000000
)(
    input                  reset,
    input                  clk,
    input                  rx,
    output reg             tx,
    output     [32 - 1: 0] RXD,
    input                  RXD_read,
    output     [32 - 1: 0] CON,
    input                  CON_read,
    input      [32 - 1: 0] TXD,
    input                  TXD_write
);

    localparam BAUD_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [3:0] rx_bit_cnt;
    reg [19:0] rx_baud_cnt;
    reg [3:0] tx_bit_cnt;
    reg [19:0] tx_baud_cnt;

    reg [8 - 1: 0] rx_buffer;
    assign RXD = {24'd0, rx_buffer};

    reg recv_done;
    reg sending;
    reg send_done;
    assign CON = {27'd0, sending, recv_done, send_done, 2'd0};

    wire [8 - 1: 0] tx_buffer;
    assign tx_buffer = TXD[7:0];

    initial begin
        tx = 1'b1;
        rx_bit_cnt = 4'd0;
        rx_baud_cnt = 20'd0;
        tx_bit_cnt = 4'd0;
        tx_baud_cnt = 20'd0;
        rx_buffer = 8'd0;
        recv_done = 1'b0;
        sending = 1'b0;
        send_done = 1'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;
            rx_bit_cnt <= 4'd0;
            rx_baud_cnt <= 20'd0;
            tx_bit_cnt <= 4'd0;
            tx_baud_cnt <= 20'd0;
            rx_buffer <= 8'd0;
            recv_done <= 1'b0;
            sending <= 1'b0;
            send_done <= 1'b0;
        end
        else begin
            if (CON_read) begin
                recv_done <= 1'b0;
                send_done <= 1'b0;
            end
            if (TXD_write) begin
                sending <= 1'b1;
            end

            // Receive
            if (rx_bit_cnt == 4'd0) begin
                if (rx_baud_cnt == BAUD_PERIOD / 2 - 1) begin
                    rx_baud_cnt <= 20'd0;
                    rx_bit_cnt <= 4'd1;
                end
                else begin
                    // Start receive only if rx is LOW for half a baud period
                    if (rx == 1'b0) rx_baud_cnt <= rx_baud_cnt + 1;
                    else rx_baud_cnt <= 20'd0;
                end
            end
            else begin
                if (rx_baud_cnt == BAUD_PERIOD - 1) begin
                    rx_baud_cnt <= 20'd0;
                    if (rx_bit_cnt == 4'd9) begin
                        recv_done <= 1'b1;
                        rx_bit_cnt <= 4'd0;
                    end
                    else begin
                        rx_buffer[rx_bit_cnt - 1] <= rx;
                        rx_bit_cnt <= rx_bit_cnt + 1;
                    end
                end
                else begin
                    rx_baud_cnt <= rx_baud_cnt + 1;
                end
            end

            // Send
            if (sending) begin
                if (tx_bit_cnt == 4'd0) tx <= 1'b0;
                else if (tx_bit_cnt == 4'd9) tx <= 1'b1;
                else tx <= tx_buffer[tx_bit_cnt - 1];

                if (tx_baud_cnt == BAUD_PERIOD - 1) begin
                    tx_baud_cnt <= 20'd0;
                    if (tx_bit_cnt == 4'd9) begin
                        sending <= 1'b0;
                        send_done <= 1'b1;
                        tx_bit_cnt <= 4'd0;
                    end
                    else begin
                        tx_bit_cnt <= tx_bit_cnt + 1;
                    end
                end
                else begin
                    tx_baud_cnt <= tx_baud_cnt + 1;
                end
            end
        end
    end

endmodule
