module InstructionMemory(
    input                  reset,
    input                  clk,
    input      [32 - 1: 0] Address,
    output reg [32 - 1: 0] Instruction
);

    // ROM size is 1024 words, each word is 32 bits, valid address is 10 bits
    parameter ROM_SIZE      = 1024;
    parameter ROM_SIZE_BIT  = 10;

    // ROM_data is an array of 1024 32-bit registers
    (* rom_style = "block" *)
    reg [32 - 1: 0] Inst_data[ROM_SIZE - 1: 0];
    integer i;
    initial begin
        for (i = 0; i < ROM_SIZE; i = i + 1) begin
            Inst_data[i] = 32'h00000000;
        end
        $readmemh("sort_uart_display.mem", Inst_data);
    end

    initial Instruction = 32'h00000000;

    always @(posedge clk) begin
        Instruction <= Inst_data[reset? 0: Address[ROM_SIZE_BIT + 1:2]];
    end

endmodule
