module Control(
    input  [6 - 1: 0] OpCode,
    input  [6 - 1: 0] Funct,
    output [2 - 1: 0] PCSrc,
    output            Branch,
    output            RegWrite,
    output [2 - 1: 0] RegDst,
    output            MemRead,
    output            MemWrite,
    output [2 - 1: 0] MemtoReg,
    output            ALUSrc1,
    output            ALUSrc2,
    output            ExtOp,
    output            LuOp,
    output [4 - 1: 0] ALUOp
);

    assign PCSrc[0] = (OpCode == 6'h02 || OpCode == 6'h03);
    assign PCSrc[1] = (OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09));
    assign Branch = (OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01);
    assign RegWrite = !(OpCode == 6'h2b || Branch || OpCode == 6'h02 || (OpCode == 6'h00 && Funct == 6'h08));
    assign RegDst[0] = (OpCode == 6'h00 || (OpCode == 6'h1c && Funct == 6'h02));
    assign RegDst[1] = (OpCode == 6'h03);
    assign MemRead = (OpCode == 6'h23);
    assign MemWrite = (OpCode == 6'h2b);
    assign MemtoReg[0] = (OpCode == 6'h23);
    assign MemtoReg[1] = (OpCode == 6'h03 || (OpCode == 6'h00 && Funct == 6'h09));
    assign ALUSrc1 = (OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03));
    assign ALUSrc2 = !(OpCode == 6'h00 || (OpCode == 6'h1c && Funct == 6'h02) || Branch);
    assign ExtOp = !(OpCode == 6'h0f || OpCode == 6'h0c);
    assign LuOp = (OpCode == 6'h0f);

    assign ALUOp[2:0] =
        (Branch)? 3'b001:
        (OpCode == 6'h1c && Funct == 6'h02)? 3'b010:
        (OpCode == 6'h0c)? 3'b100:
        (OpCode == 6'h0d)? 3'b101:
        (OpCode == 6'h0a || OpCode == 6'h0b)? 3'b110:
        (OpCode == 6'h00)? 3'b111:
        3'b000;
    assign ALUOp[3] = OpCode[0];

endmodule
