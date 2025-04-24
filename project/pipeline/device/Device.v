module Device #(
    parameter CLK_FREQ = 100000000
)(
    input                  reset,
    input                  clk,
    input                  Read,
    input                  Write,
    input      [32 - 1: 0] Address,
    output     [32 - 1: 0] Read_data,
    input      [32 - 1: 0] Write_data,
    output reg [4  - 1: 0] sel,
    output reg [7  - 1: 0] seg,
    output reg             dp,
    input                  rx,
    output                 tx
);

    wire [32 - 1: 0] UART_RXD;
    wire             UART_RXD_read;
    wire [32 - 1: 0] UART_CON;
    wire             UART_CON_read;
    reg  [32 - 1: 0] UART_TXD;
    wire             UART_TXD_write;

    assign UART_RXD_read = Read && (Address == 32'h4000001C);
    assign UART_CON_read = Read && (Address == 32'h40000020);
    assign UART_TXD_write = Write && (Address == 32'h40000018);

    assign Read_data =
        UART_RXD_read? UART_RXD:
        UART_CON_read? UART_CON:
        32'h00000000;

    UART #(
        .BAUD_RATE (9600),
        .CLK_FREQ  (CLK_FREQ)
    ) uart1 (
        .reset     (reset          ),
        .clk       (clk            ),
        .rx        (rx             ),
        .tx        (tx             ),
        .RXD       (UART_RXD       ),
        .RXD_read  (UART_RXD_read  ),
        .CON       (UART_CON       ),
        .CON_read  (UART_CON_read  ),
        .TXD       (UART_TXD       ),
        .TXD_write (UART_TXD_write )
    );

    initial begin
        sel = 4'd0;
        dp = 1'd0;
        seg = 7'd0;
        UART_TXD = 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sel <= 4'd0;
            dp <= 1'd0;
            seg <= 7'd0;
            UART_TXD <= 32'h00000000;
        end
        else begin
            if (Write) begin
                case (Address)
                    32'h40000010: begin
                        // write to 7-segment display
                        sel <= Write_data[11:8];
                        dp <= Write_data[7];
                        seg <= Write_data[6:0];
                    end
                    32'h40000018: begin
                        // write to UART_TXD
                        UART_TXD <= Write_data;
                    end
                endcase
            end
        end
    end

endmodule
