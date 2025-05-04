module CPU(
    input              reset,
    input              clk,
    output             Device_Read,
    output             Device_Write,
    output [32 - 1: 0] MemBus_Address,
    input  [32 - 1: 0] Device_Read_Data,
    output [32 - 1: 0] MemBus_Write_Data
);

    // PC register
    reg  [32 - 1: 0] PC;
    wire [32 - 1: 0] PC_next;
    wire [32 - 1: 0] PC_plus_4;

    initial PC = 32'h00000000;
    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 32'h00000000;
        else PC <= PC_next;
    end

    assign PC_plus_4 = PC + 32'd4;

    // Instruction Memory
    wire [32 - 1: 0] Instruction;
    InstructionMemory instruction_memory1(
        .Address     (PC          ),
        .Instruction (Instruction )
    );

    // Control
    wire [2 - 1: 0] PCSrc;
    wire            RegWrite;
    wire [2 - 1: 0] RegDst;
    wire            MemRead;
    wire            MemWrite;
    wire [2 - 1: 0] MemtoReg;
    wire            ALUSrc1;
    wire            ALUSrc2;
    wire            ExtOp;
    wire            LuOp;
    wire [4 - 1: 0] ALUOp;

    Control control1(
        .OpCode   (Instruction[31:26] ),
        .Funct    (Instruction[5:0]   ),
        .PCSrc    (PCSrc              ),
        .RegWrite (RegWrite           ),
        .RegDst   (RegDst             ),
        .MemRead  (MemRead            ),
        .MemWrite (MemWrite           ),
        .MemtoReg (MemtoReg           ),
        .ALUSrc1  (ALUSrc1            ),
        .ALUSrc2  (ALUSrc2            ),
        .ExtOp    (ExtOp              ),
        .LuOp     (LuOp               ),
        .ALUOp    (ALUOp              )
    );

    // Register File
    wire [32 - 1: 0] Databus1;
    wire [32 - 1: 0] Databus2;
    wire [32 - 1: 0] Databus3;
    wire [5  - 1: 0] Write_register;

    assign Write_register =
        (RegDst == 2'b00)? Instruction[20:16]:
        (RegDst == 2'b01)? Instruction[15:11]: 5'b11111;

    RegisterFile register_file1(
        .reset          (reset              ),
        .clk            (clk                ),
        .Read_register1 (Instruction[25:21] ),
        .Read_data1     (Databus1           ),
        .Read_register2 (Instruction[20:16] ),
        .Read_data2     (Databus2           ),
        .Write          (RegWrite           ),
        .Write_register (Write_register     ),
        .Write_data     (Databus3           )
    );

    // Extend
    wire [32 - 1: 0] Ext_out;
    assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};

    wire [32 - 1: 0] LU_out;
    assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;

    // ALU Control
    wire [4 - 1: 0] ALUCtl;
    wire            Sign;

    ALUControl alu_control1(
        .ALUOp  (ALUOp            ),
        .Funct  (Instruction[5:0] ),
        .ALUCtl (ALUCtl           ),
        .Sign   (Sign             )
    );

    // ALU
    wire [32 - 1: 0] ALU_in1;
    wire [32 - 1: 0] ALU_in2;
    wire [32 - 1: 0] ALU_out;

    assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: Databus1;
    assign ALU_in2 = ALUSrc2? LU_out: Databus2;

    ALU alu1(
        .in1    (ALU_in1 ),
        .in2    (ALU_in2 ),
        .ALUCtl (ALUCtl  ),
        .Sign   (Sign    ),
        .out    (ALU_out )
    );

    // Data Memory
    wire             is_Memory;
    wire [32 - 1: 0] Memory_Read_Data;
    wire             Memory_Read;
    wire             Memory_Write;
    wire [32 - 1: 0] MemBus_Read_Data;

    assign MemBus_Address = ALU_out;
    assign is_Memory = MemBus_Address < 32'h40000000;
    assign Memory_Read = MemRead && is_Memory;
    assign Memory_Write = MemWrite && is_Memory;
    assign Device_Read = MemRead && !is_Memory;
    assign Device_Write = MemWrite && !is_Memory;
    assign MemBus_Read_Data = is_Memory? Memory_Read_Data: Device_Read_Data;
    assign MemBus_Write_Data = Databus2;

    DataMemory data_memory1(
        .reset      (reset             ),
        .clk        (clk               ),
        .Read       (Memory_Read       ),
        .Write      (Memory_Write      ),
        .Address    (MemBus_Address    ),
        .Read_data  (Memory_Read_Data  ),
        .Write_data (MemBus_Write_Data )
    );

    // write back
    assign Databus3 =
        (MemtoReg == 2'b00)? ALU_out:
        (MemtoReg == 2'b01)? MemBus_Read_Data: PC_plus_4;

    // PC jump and branch
    wire [32 - 1: 0] Jump_target;
    assign Jump_target = {PC_plus_4[31:28], Instruction[25:0], 2'b00};

    wire Branch_condition;
    assign Branch_condition =
        (Instruction[31:26] == 6'h04 && Databus1 == Databus2) ||
        (Instruction[31:26] == 6'h05 && Databus1 != Databus2) ||
        (Instruction[31:26] == 6'h06 && (Databus1[31] == 1'b1 || Databus1 == 0)) ||
        (Instruction[31:26] == 6'h07 && (Databus1[31] == 1'b0 && Databus1 != 0)) ||
        (Instruction[31:26] == 6'h01 && Databus1[31] == 1'b1);
    wire [32 - 1: 0] Branch_target;
    assign Branch_target = Branch_condition? (PC_plus_4 + {LU_out[29:0], 2'b00}): PC_plus_4;

    assign PC_next =
        (PCSrc == 2'b00)? Branch_target:
        (PCSrc == 2'b01)? Jump_target: Databus1;

endmodule
