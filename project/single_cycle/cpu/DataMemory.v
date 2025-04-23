module DataMemory(
    input              reset,
    input              clk,
    input              Read,
    input              Write,
    input  [32 - 1: 0] Address,
    output [32 - 1: 0] Read_data,
    input  [32 - 1: 0] Write_data
);

    // RAM size is 1024 words, each word is 32 bits, valid address is 10 bits
    parameter RAM_SIZE = 1024;
    parameter RAM_SIZE_BIT = 10;

    // RAM_data is an array of 1024 32-bit registers
    (* ram_style = "distributed" *)
    reg [32 - 1: 0] RAM_data [RAM_SIZE - 1: 0];
    integer i;
    initial begin
        for (i = 0; i < RAM_SIZE; i = i + 1) begin
            RAM_data[i] = 32'h00000000;
        end
        $readmemh("ram.mem", RAM_data);
    end

    // read data from RAM_data as Read_data
    assign Read_data = Read? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;

    // write Write_data to RAM_data at clock posedge
    always @(posedge clk) begin
        if (!reset && Write) begin
            RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
        end
    end

endmodule
