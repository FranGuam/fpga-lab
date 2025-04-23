module ALUControl(
    input      [4 - 1: 0] ALUOp,
    input      [6 - 1: 0] Funct,
    output reg [4 - 1: 0] ALUCtl,
    output                Sign
);

    // funct number for different operation
    parameter aluADD = 4'd0;
    parameter aluSUB = 4'd1;
    parameter aluMUL = 4'd2;
    parameter aluAND = 4'd4;
    parameter aluOR  = 4'd5;
    parameter aluXOR = 4'd6;
    parameter aluNOR = 4'd7;
    parameter aluSLL = 4'd8;
    parameter aluSRL = 4'd9;
    parameter aluSRA = 4'd10;
    parameter aluSLT = 4'd11;

    // whether the ALU treats the input as a signed number or an unsigned number
    // used only for slt, sltu, slti, sltiu
    assign Sign = (ALUOp[2:0] == 3'b111)? ~Funct[0]: ~ALUOp[3];

    // set aluFunct
    reg [4:0] aluFunct;
    always @(*) begin
        case (Funct)
            6'h00: aluFunct <= aluSLL;
            6'h02: aluFunct <= aluSRL;
            6'h03: aluFunct <= aluSRA;
            6'h20: aluFunct <= aluADD;
            6'h21: aluFunct <= aluADD;
            6'h22: aluFunct <= aluSUB;
            6'h23: aluFunct <= aluSUB;
            6'h24: aluFunct <= aluAND;
            6'h25: aluFunct <= aluOR;
            6'h26: aluFunct <= aluXOR;
            6'h27: aluFunct <= aluNOR;
            6'h2a: aluFunct <= aluSLT;
            6'h2b: aluFunct <= aluSLT;
            default: aluFunct <= aluADD;
        endcase
    end

    // set ALUCtrl
    always @(*) begin
        case (ALUOp[2:0])
            3'b000: ALUCtl <= aluADD;
            3'b001: ALUCtl <= aluSUB;
            3'b010: ALUCtl <= aluMUL;
            3'b100: ALUCtl <= aluAND;
            3'b101: ALUCtl <= aluOR;
            3'b110: ALUCtl <= aluSLT;
            3'b111: ALUCtl <= aluFunct;
            default: ALUCtl <= aluADD;
        endcase
    end

endmodule
