module ForwardingUnit(
    input      [5 - 1: 0] IF_ID_Rs,
    input      [5 - 1: 0] IF_ID_Rt,
    input      [5 - 1: 0] ID_EX_Write_register,
    input      [5 - 1: 0] EX_MEM_Write_register,
    input                 ID_EX_RegWrite,
    input                 EX_MEM_RegWrite,
    output reg [2 - 1: 0] ForwardA,
    output reg [2 - 1: 0] ForwardB
);

    always @(*) begin
        // Forward A
        if (ID_EX_RegWrite && (ID_EX_Write_register != 0) && (ID_EX_Write_register == IF_ID_Rs))
            ForwardA <= 2'b10;  // Forward from EX Stage
        else if (EX_MEM_RegWrite && (EX_MEM_Write_register != 0) && (EX_MEM_Write_register == IF_ID_Rs))
            ForwardA <= 2'b01;  // Forward from MEM Stage
        else
            ForwardA <= 2'b00;  // No forwarding

        // Forward B
        if (ID_EX_RegWrite && (ID_EX_Write_register != 0) && (ID_EX_Write_register == IF_ID_Rt))
            ForwardB <= 2'b10;  // Forward from EX Stage
        else if (EX_MEM_RegWrite && (EX_MEM_Write_register != 0) && (EX_MEM_Write_register == IF_ID_Rt))
            ForwardB <= 2'b01;  // Forward from MEM Stage
        else
            ForwardB <= 2'b00;  // No forwarding
    end

endmodule
