`timescale 1ns / 1ps

module testbench ();
// Generate clock
reg clk;
initial clk = 0;
always #5 clk = ~clk;

// Other signals
reg rst;
reg mem2uart;
reg Rx_Serial;
wire recv_done;
wire send_done;
wire Tx_Serial;
initial begin
    rst = 1;
    mem2uart = 0;
    Rx_Serial = 1;
    #123;
    rst = 0;
end

// Read input
parameter BYTE_LENGTH = 128;
reg [7:0] msg [0:2*BYTE_LENGTH-1];
initial $readmemh("../../../../../hex.txt", msg);

// Instantiate UART_MEM
UART_MEM uart_mem(
    .clk(clk),
    .rst(rst),
    .mem2uart(mem2uart),
    .recv_done(recv_done),
    .send_done(send_done),
    .Rx_Serial(Rx_Serial),
    .Tx_Serial(Tx_Serial)
);

// Test
reg pass;
integer i;
integer j;
reg [7:0] msg_out [0:BYTE_LENGTH-1];
initial begin
    pass = 1;
    #123456; // Random delay
    for (i = 0; i < 2*BYTE_LENGTH; i = i + 1) begin
        // Start bit
        Rx_Serial = 0;
        #104167; // ns for 1 bit under 9600 baudrate
        // Data bits
        for (j = 0; j < 8; j = j + 1) begin
            Rx_Serial = msg[i][j];
            #104167;
        end
        // Stop bit
        Rx_Serial = 1;
        #156250; // ns for 1.5 bit under 9600 baudrate
    end
    if (recv_done != 1) begin
        pass = 0;
        $display("Error: recv_done is false");
    end

    #123456;
    mem2uart = 1;
    for (i = 0; i < BYTE_LENGTH; i = i + 1) begin
        while (Tx_Serial == 1) #10;
        #156250;
        for (j = 0; j < 8; j = j + 1) begin
            msg_out[i][j] = Tx_Serial;
            #104167;
        end
        if (msg_out[i] != msg[i + BYTE_LENGTH]) begin
            pass = 0;
            $display("Error: data mismatch at %d", i);
        end
    end
    if (send_done != 1) begin
        pass = 0;
        $display("Error: send_done is false");
    end

    if (pass) $display("Test passed");
    else $display("Test failed");
    $finish;
end

endmodule
