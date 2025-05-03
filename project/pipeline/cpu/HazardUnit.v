module HazardUnit(
    input  [5 - 1: 0] IF_ID_Rs,
    input  [5 - 1: 0] IF_ID_Rt,
    input  [5 - 1: 0] ID_EX_Rt,
    input             ID_EX_MemRead,
    input             Jump,
    input             Branch_missed,
    output            PC_Stall,
    output            IF_ID_Flush,
    output            IF_ID_Stall,
    output            ID_EX_Flush
);

    wire Load_use_hazard;
    assign Load_use_hazard = ID_EX_MemRead && ((ID_EX_Rt == IF_ID_Rs) || (ID_EX_Rt == IF_ID_Rt));

    wire Stall_one;
    assign Stall_one = Load_use_hazard;

    wire Flush_one;
    assign Flush_one = Jump;

    wire Flush_two;
    assign Flush_two = Branch_missed;

    assign PC_Stall = Stall_one;
    assign IF_ID_Flush = Flush_one || Flush_two;
    assign IF_ID_Stall = Stall_one;
    assign ID_EX_Flush = Stall_one || Flush_two;

endmodule
