module RegisterFile(
    input              reset,
    input              clk,
    input  [5  - 1: 0] Read_register1,
    output [32 - 1: 0] Read_data1,
    input  [5  - 1: 0] Read_register2,
    output [32 - 1: 0] Read_data2,
    input              Write,
    input  [5  - 1: 0] Write_register,
    input  [32 - 1: 0] Write_data
);

    // RF_data is an array of 32 32-bit registers
    // here RF_data[0] is not defined because RF_data[0] identically equal to 0
    reg [32 - 1: 0] RF_data[31:1];
    integer i;
    initial begin
        for (i = 1; i < 32; i = i + 1) begin
            RF_data[i] = 32'h00000000;
        end
    end

    // read data from RF_data as Read_data1 and Read_data2
    assign Read_data1 = (Read_register1 == 5'b00000)? 32'h00000000: RF_data[Read_register1];
    assign Read_data2 = (Read_register2 == 5'b00000)? 32'h00000000: RF_data[Read_register2];

    // write Wrtie_data to RF_data at clock posedge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1) begin
                RF_data[i] <= 32'h00000000;
            end
        end
        else if (Write && (Write_register != 5'b00000)) begin
            RF_data[Write_register] <= Write_data;
        end
    end

endmodule
