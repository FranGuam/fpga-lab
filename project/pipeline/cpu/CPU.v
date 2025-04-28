module CPU(
    input              reset,
    input              clk,
    output             Device_Read,
    output             Device_Write,
    output [32 - 1: 0] MemBus_Address,
    input  [32 - 1: 0] Device_Read_Data,
    output [32 - 1: 0] MemBus_Write_Data
);

    /* IF stage */

    // PC register
    reg  [32 - 1: 0] PC;
    wire [32 - 1: 0] PC_next;
    wire [32 - 1: 0] PC_plus_4;

    initial PC = 32'h00000000;
    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 32'h00000000;
        else if (!PC_Stall) PC <= PC_next;
    end

    assign PC_plus_4 = PC + 32'd4;

    assign PC_next =
        (ID_EX_PCSrc == 2'b00)? (Branch_condition? Branch_target: PC_plus_4):
        (ID_EX_PCSrc == 2'b01)? Jump_target: ID_EX_Databus1;

    // Instruction Memory
    wire [32 - 1: 0] Instruction;
    InstructionMemory instruction_memory1(
        .Address     (PC          ),
        .Instruction (Instruction )
    );

    /* IF/ID pipeline registers */

    reg  [32 - 1: 0] IF_ID_PC_plus_4;
    reg  [32 - 1: 0] IF_ID_Instruction;

    initial begin
        IF_ID_PC_plus_4 <= 32'h00000000;
        IF_ID_Instruction <= 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset || IF_ID_Flush) begin
            IF_ID_PC_plus_4 <= 32'h00000000;
            IF_ID_Instruction <= 32'h00000000;
        end
        else if (!IF_ID_Stall) begin
            IF_ID_PC_plus_4 <= PC_plus_4;
            IF_ID_Instruction <= Instruction;
        end
    end

    /* ID stage */

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
        .OpCode   (IF_ID_Instruction[31:26] ),
        .Funct    (IF_ID_Instruction[5:0]   ),
        .PCSrc    (PCSrc                    ),
        .RegWrite (RegWrite                 ),
        .RegDst   (RegDst                   ),
        .MemRead  (MemRead                  ),
        .MemWrite (MemWrite                 ),
        .MemtoReg (MemtoReg                 ),
        .ALUSrc1  (ALUSrc1                  ),
        .ALUSrc2  (ALUSrc2                  ),
        .ExtOp    (ExtOp                    ),
        .LuOp     (LuOp                     ),
        .ALUOp    (ALUOp                    )
    );

    // Register File
    wire [32 - 1: 0] Databus1;
    wire [32 - 1: 0] Databus2;
    wire [5  - 1: 0] Write_register;

    assign Write_register =
        (RegDst == 2'b00)? IF_ID_Instruction[20:16]:
        (RegDst == 2'b01)? IF_ID_Instruction[15:11]: 5'b11111;

    RegisterFile register_file1(
        .reset          (reset                    ),
        .clk            (clk                      ),
        .Read_register1 (IF_ID_Instruction[25:21] ),
        .Read_data1     (Databus1                 ),
        .Read_register2 (IF_ID_Instruction[20:16] ),
        .Read_data2     (Databus2                 ),
        .Write          (MEM_WB_RegWrite          ),
        .Write_register (MEM_WB_Write_register    ),
        .Write_data     (MEM_WB_Databus3          )
    );

    wire [32 - 1: 0] Databus1_forwarded;
    wire [32 - 1: 0] Databus2_forwarded;

    assign Databus1_forwarded =
        (ForwardA == 2'b10)? ALU_out:
        (ForwardA == 2'b01)? Databus3: Databus1;
    assign Databus2_forwarded =
        (ForwardB == 2'b10)? ALU_out:
        (ForwardB == 2'b01)? Databus3: Databus2;

    // Extend
    wire [32 - 1: 0] Ext_out;
    assign Ext_out = {ExtOp? {16{IF_ID_Instruction[15]}}: 16'h0000, IF_ID_Instruction[15:0]};

    wire [32 - 1: 0] LU_out;
    assign LU_out = LuOp? {IF_ID_Instruction[15:0], 16'h0000}: Ext_out;

    /* ID/EX pipeline registers */

    reg [32 - 1: 0] ID_EX_PC_plus_4;
    reg [32 - 1: 0] ID_EX_Instruction;

    reg [2  - 1: 0] ID_EX_PCSrc;
    reg             ID_EX_ALUSrc1;
    reg             ID_EX_ALUSrc2;
    reg [4  - 1: 0] ID_EX_ALUOp;

    reg             ID_EX_MemRead;
    reg             ID_EX_MemWrite;
    reg [2  - 1: 0] ID_EX_MemtoReg;

    reg             ID_EX_RegWrite;
    reg [5  - 1: 0] ID_EX_Write_register;

    reg [32 - 1: 0] ID_EX_Databus1;
    reg [32 - 1: 0] ID_EX_Databus2;
    reg [32 - 1: 0] ID_EX_LU_out;

    initial begin
        ID_EX_PC_plus_4 <= 32'h00000000;
        ID_EX_Instruction <= 32'h00000000;
        ID_EX_PCSrc <= 2'b00;
        ID_EX_ALUSrc1 <= 1'b0;
        ID_EX_ALUSrc2 <= 1'b0;
        ID_EX_ALUOp <= 4'h0;
        ID_EX_MemRead <= 1'b0;
        ID_EX_MemWrite <= 1'b0;
        ID_EX_MemtoReg <= 2'b00;
        ID_EX_RegWrite <= 1'b0;
        ID_EX_Write_register <= 5'b00000;
        ID_EX_Databus1 <= 32'h00000000;
        ID_EX_Databus2 <= 32'h00000000;
        ID_EX_LU_out <= 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset || ID_EX_Flush) begin
            ID_EX_PC_plus_4 <= 32'h00000000;
            ID_EX_Instruction <= 32'h00000000;
            ID_EX_PCSrc <= 2'b00;
            ID_EX_ALUSrc1 <= 1'b0;
            ID_EX_ALUSrc2 <= 1'b0;
            ID_EX_ALUOp <= 4'h0;
            ID_EX_MemRead <= 1'b0;
            ID_EX_MemWrite <= 1'b0;
            ID_EX_MemtoReg <= 2'b00;
            ID_EX_RegWrite <= 1'b0;
            ID_EX_Write_register <= 5'b00000;
            ID_EX_Databus1 <= 32'h00000000;
            ID_EX_Databus2 <= 32'h00000000;
            ID_EX_LU_out <= 32'h00000000;
        end
        else begin
            ID_EX_PC_plus_4 <= IF_ID_PC_plus_4;
            ID_EX_Instruction <= IF_ID_Instruction;
            ID_EX_PCSrc <= PCSrc;
            ID_EX_ALUSrc1 <= ALUSrc1;
            ID_EX_ALUSrc2 <= ALUSrc2;
            ID_EX_ALUOp <= ALUOp;
            ID_EX_MemRead <= MemRead;
            ID_EX_MemWrite <= MemWrite;
            ID_EX_MemtoReg <= MemtoReg;
            ID_EX_RegWrite <= RegWrite;
            ID_EX_Write_register <= Write_register;
            ID_EX_Databus1 <= Databus1_forwarded;
            ID_EX_Databus2 <= Databus2_forwarded;
            ID_EX_LU_out <= LU_out;
        end
    end

    /* EX stage */

    // ALU Control
    wire [4 - 1: 0] ALUCtl;
    wire            Sign;

    ALUControl alu_control1(
        .ALUOp  (ID_EX_ALUOp            ),
        .Funct  (ID_EX_Instruction[5:0] ),
        .ALUCtl (ALUCtl                 ),
        .Sign   (Sign                   )
    );

    // ALU
    wire [32 - 1: 0] ALU_in1;
    wire [32 - 1: 0] ALU_in2;
    wire [32 - 1: 0] ALU_out;

    assign ALU_in1 = ID_EX_ALUSrc1? {27'h00000, ID_EX_Instruction[10:6]}: ID_EX_Databus1;
    assign ALU_in2 = ID_EX_ALUSrc2? ID_EX_LU_out: ID_EX_Databus2;

    ALU alu1(
        .in1    (ALU_in1 ),
        .in2    (ALU_in2 ),
        .ALUCtl (ALUCtl  ),
        .Sign   (Sign    ),
        .out    (ALU_out )
    );

    // PC jump and branch
    wire [32 - 1: 0] Jump_target;
    assign Jump_target = {ID_EX_PC_plus_4[31:28], ID_EX_Instruction[25:0], 2'b00};

    wire Branch_condition;
    assign Branch_condition =
        (ID_EX_Instruction[31:26] == 6'h04 && ID_EX_Databus1 == ID_EX_Databus2) ||
        (ID_EX_Instruction[31:26] == 6'h05 && ID_EX_Databus1 != ID_EX_Databus2) ||
        (ID_EX_Instruction[31:26] == 6'h06 && (ID_EX_Databus1[31] == 1'b1 || ID_EX_Databus1 == 0)) ||
        (ID_EX_Instruction[31:26] == 6'h07 && (ID_EX_Databus1[31] == 1'b0 && ID_EX_Databus1 != 0)) ||
        (ID_EX_Instruction[31:26] == 6'h01 && ID_EX_Databus1[31] == 1'b1);
    wire [32 - 1: 0] Branch_target;
    assign Branch_target = ID_EX_PC_plus_4 + {ID_EX_LU_out[29:0], 2'b00};

    /* EX/MEM pipeline registers */

    reg [32 - 1: 0] EX_MEM_PC_plus_4;

    reg             EX_MEM_MemRead;
    reg             EX_MEM_MemWrite;
    reg [2  - 1: 0] EX_MEM_MemtoReg;

    reg             EX_MEM_RegWrite;
    reg [5  - 1: 0] EX_MEM_Write_register;

    reg [32 - 1: 0] EX_MEM_ALU_out;
    reg [32 - 1: 0] EX_MEM_Databus2;

    initial begin
        EX_MEM_PC_plus_4 <= 32'h00000000;
        EX_MEM_MemRead <= 1'b0;
        EX_MEM_MemWrite <= 1'b0;
        EX_MEM_MemtoReg <= 2'b00;
        EX_MEM_RegWrite <= 1'b0;
        EX_MEM_Write_register <= 5'h00;
        EX_MEM_ALU_out <= 32'h00000000;
        EX_MEM_Databus2 <= 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_PC_plus_4 <= 32'h00000000;
            EX_MEM_MemRead <= 1'b0;
            EX_MEM_MemWrite <= 1'b0;
            EX_MEM_MemtoReg <= 2'b00;
            EX_MEM_RegWrite <= 1'b0;
            EX_MEM_Write_register <= 5'h00;
            EX_MEM_ALU_out <= 32'h00000000;
            EX_MEM_Databus2 <= 32'h00000000;
        end
        else begin
            EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemtoReg <= ID_EX_MemtoReg;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_Write_register <= ID_EX_Write_register;
            EX_MEM_ALU_out <= ALU_out;
            EX_MEM_Databus2 <= ID_EX_Databus2;
        end
    end

    /* MEM stage */

    // Data Memory
    wire             is_Memory;
    wire [32 - 1: 0] Memory_Read_Data;
    wire             Memory_Read;
    wire             Memory_Write;
    wire [32 - 1: 0] MemBus_Read_Data;

    assign MemBus_Address = EX_MEM_ALU_out;
    assign is_Memory = MemBus_Address < 32'h40000000;
    assign Memory_Read = EX_MEM_MemRead && is_Memory;
    assign Memory_Write = EX_MEM_MemWrite && is_Memory;
    assign Device_Read = EX_MEM_MemRead && !is_Memory;
    assign Device_Write = EX_MEM_MemWrite && !is_Memory;
    assign MemBus_Read_Data = is_Memory? Memory_Read_Data: Device_Read_Data;
    assign MemBus_Write_Data = EX_MEM_Databus2;

    DataMemory data_memory1(
        .reset      (reset             ),
        .clk        (clk               ),
        .Read       (Memory_Read       ),
        .Write      (Memory_Write      ),
        .Address    (MemBus_Address    ),
        .Read_data  (Memory_Read_Data  ),
        .Write_data (MemBus_Write_Data )
    );

    wire [32 - 1: 0] Databus3;
    assign Databus3 =
        (EX_MEM_MemtoReg == 2'b00)? EX_MEM_ALU_out:
        (EX_MEM_MemtoReg == 2'b01)? MemBus_Read_Data: EX_MEM_PC_plus_4;

    /* MEM/WB pipeline registers */

    reg             MEM_WB_RegWrite;
    reg [5  - 1: 0] MEM_WB_Write_register;

    reg [32 - 1: 0] MEM_WB_Databus3;

    initial begin
        MEM_WB_RegWrite <= 1'b0;
        MEM_WB_Write_register <= 5'h00;
        MEM_WB_Databus3 <= 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_RegWrite <= 1'b0;
            MEM_WB_Write_register <= 5'h00;
            MEM_WB_Databus3 <= 32'h00000000;
        end
        else begin
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_Write_register <= EX_MEM_Write_register;
            MEM_WB_Databus3 <= Databus3;
        end
    end

    /* WB stage */
    // Already included in Register File

    /* Forwarding Unit */

    wire [2 - 1: 0] ForwardA;
    wire [2 - 1: 0] ForwardB;

    ForwardingUnit forwarding_unit1(
        .IF_ID_Rs              (IF_ID_Instruction[25:21] ),
        .IF_ID_Rt              (IF_ID_Instruction[20:16] ),
        .ID_EX_Write_register  (ID_EX_Write_register     ),
        .EX_MEM_Write_register (EX_MEM_Write_register    ),
        .ID_EX_RegWrite        (ID_EX_RegWrite           ),
        .EX_MEM_RegWrite       (EX_MEM_RegWrite          ),
        .ForwardA              (ForwardA                 ),
        .ForwardB              (ForwardB                 )
    );

    /* Hazard Detection Unit */

    wire PC_Stall;
    wire IF_ID_Flush;
    wire IF_ID_Stall;
    wire ID_EX_Flush;

    HazardUnit hazard_unit1(
        .IF_ID_Rs      (IF_ID_Instruction[25:21] ),
        .IF_ID_Rt      (IF_ID_Instruction[20:16] ),
        .ID_EX_Rt      (ID_EX_Instruction[20:16] ),
        .ID_EX_MemRead (ID_EX_MemRead            ),
        .Jump          (ID_EX_PCSrc != 2'b00     ),
        .Branch        (Branch_condition         ),
        .PC_Stall      (PC_Stall                 ),
        .IF_ID_Flush   (IF_ID_Flush              ),
        .IF_ID_Stall   (IF_ID_Stall              ),
        .ID_EX_Flush   (ID_EX_Flush              )
    );

endmodule
