module ForwardingUnit(
    input      [5 - 1: 0] IF_ID_Rs,
    input      [5 - 1: 0] ID_EX_Rs,
    input      [5 - 1: 0] ID_EX_Rt,
    input      [5 - 1: 0] ID_EX_Write_register,
    input      [5 - 1: 0] EX_MEM_Write_register,
    input      [5 - 1: 0] MEM_WB_Write_register,
    input                 ID_EX_RegWrite,
    input                 EX_MEM_RegWrite,
    input                 MEM_WB_RegWrite,
    output reg [2 - 1: 0] ForwardA,
    output reg [2 - 1: 0] ForwardB,
    output reg [2 - 1: 0] ForwardJump
);

    always @(*) begin
        // Forward A
        if (EX_MEM_RegWrite && (EX_MEM_Write_register != 0) && (EX_MEM_Write_register == ID_EX_Rs))
            ForwardA <= 2'b10;  // Forward from EX/MEM
        else if (MEM_WB_RegWrite && (MEM_WB_Write_register != 0) && (MEM_WB_Write_register == ID_EX_Rs))
            ForwardA <= 2'b01;  // Forward from MEM/WB
        else
            ForwardA <= 2'b00;  // No forwarding

        // Forward B
        if (EX_MEM_RegWrite && (EX_MEM_Write_register != 0) && (EX_MEM_Write_register == ID_EX_Rt))
            ForwardB <= 2'b10;  // Forward from EX/MEM
        else if (MEM_WB_RegWrite && (MEM_WB_Write_register != 0) && (MEM_WB_Write_register == ID_EX_Rt))
            ForwardB <= 2'b01;  // Forward from MEM/WB
        else
            ForwardB <= 2'b00;  // No forwarding

        // Forward Jump
        if (EX_MEM_RegWrite && (EX_MEM_Write_register != 0) && (EX_MEM_Write_register == IF_ID_Rs))
            ForwardJump <= 2'b10;  // Forward from EX/MEM
        else if (ID_EX_RegWrite && (ID_EX_Write_register != 0) && (ID_EX_Write_register == IF_ID_Rs))
            ForwardJump <= 2'b01;  // Forward from ID/EX
        else
            ForwardJump <= 2'b00;  // No forwarding
    end

endmodule
