module BranchPredictor(
    input              reset,
    input              clk,
    // Inputs for prediction
    input  [32 - 1: 0] PC_IF,
    // Inputs for update
    input  [32 - 1: 0] PC_EX,
    input              ID_EX_Branch,
    input              Branch_taken,
    input  [32 - 1: 0] Branch_target,
    // Outputs for prediction
    output             BHT_hit,
    output             Predict_taken,
    output [32 - 1: 0] Predict_target
);

    parameter BHT_SIZE = 32;
    parameter BHT_SIZE_BIT = 5;
    parameter ROM_SIZE_BIT = 10;
    localparam TAG_SIZE_BIT = ROM_SIZE_BIT - BHT_SIZE_BIT;

    // Branch History Table (BHT) - stores 2-bit saturating counters
    // 00: strongly not taken, 01: weakly not taken, 10: weakly taken, 11: strongly taken
    reg [2 - 1: 0] BHT_counter [BHT_SIZE - 1: 0];
    reg [TAG_SIZE_BIT - 1: 0] BHT_tag [BHT_SIZE - 1: 0];
    reg BHT_valid [BHT_SIZE - 1: 0];
    // Branch Target Buffer (BTB) - stores branch target addresses
    reg [32 - 1: 0] BTB_target [BHT_SIZE - 1: 0];

    // Index and tag extraction for IF stage
    wire [BHT_SIZE_BIT - 1: 0] index_IF;
    wire [TAG_SIZE_BIT - 1: 0] tag_IF;

    assign index_IF = PC_IF[BHT_SIZE_BIT + 1: 2];
    assign tag_IF = PC_IF[ROM_SIZE_BIT + 1: BHT_SIZE_BIT + 2];

    // Prediction logic
    assign BHT_hit = BHT_valid[index_IF] && (BHT_tag[index_IF] == tag_IF);
    assign Predict_taken = BHT_counter[index_IF][1];
    assign Predict_target = BTB_target[index_IF];

    // Index and tag extraction for EX stage
    wire [BHT_SIZE_BIT - 1: 0] index_EX;
    wire [TAG_SIZE_BIT - 1: 0] tag_EX;

    assign index_EX = PC_EX[BHT_SIZE_BIT + 1: 2];
    assign tag_EX = PC_EX[ROM_SIZE_BIT + 1: BHT_SIZE_BIT + 2];

    integer i;
    initial begin
        for (i = 0; i < BHT_SIZE; i = i + 1) begin
            BHT_valid[i] = 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                BHT_valid[i] <= 1'b0;
            end
        end
        else if (ID_EX_Branch) begin
            // Update BTB entry
            BTB_target[index_EX] <= Branch_target;
            BHT_valid[index_EX] <= 1'b1;
            BHT_tag[index_EX] <= tag_EX;

            if (BHT_valid[index_EX] && (BHT_tag[index_EX] == tag_EX)) begin
                // Update 2-bit saturating counter
                case (BHT_counter[index_EX])
                    2'b00: BHT_counter[index_EX] <= Branch_taken? 2'b01: 2'b00;
                    2'b01: BHT_counter[index_EX] <= Branch_taken? 2'b10: 2'b00;
                    2'b10: BHT_counter[index_EX] <= Branch_taken? 2'b11: 2'b01;
                    2'b11: BHT_counter[index_EX] <= Branch_taken? 2'b11: 2'b10;
                endcase
            end
            else begin
                // Initialize 2-bit saturating counter
                BHT_counter[index_EX] <= Branch_taken? 2'b10: 2'b01;
            end
        end
    end

endmodule
