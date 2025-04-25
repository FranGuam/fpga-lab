module ALU(
    input      [32 - 1: 0] in1,
    input      [32 - 1: 0] in2,
    input      [4  - 1: 0] ALUCtl,
    input                  Sign,
    output reg [32 - 1: 0] out
);

    // lt_signed means whether (in1 < in2) in signed number
    wire lt_signed;
    assign lt_signed = (in1[31] ^ in2[31])? (in1[31] == 1'b1 && in2[31] == 1'b0): (in1[30:0] < in2[30:0]);

    wire [32 - 1: 0] mult_out;
    mult_gen_0 mult1(
        .A (in1      ),
        .B (in2      ),
        .P (mult_out )
    );

    // different ALU operations
    always @(*) begin
        case (ALUCtl)
            4'd0: out <= in1 + in2;
            4'd1: out <= in1 - in2;
            4'd2: out <= mult_out;
            4'd4: out <= in1 & in2;
            4'd5: out <= in1 | in2;
            4'd6: out <= in1 ^ in2;
            4'd7: out <= ~(in1 | in2);
            4'd8: out <= (in2 << in1[4:0]);
            4'd9: out <= (in2 >> in1[4:0]);
            4'd10: out <= ({{32{in2[31]}}, in2} >> in1[4:0]);
            4'd11: out <= {31'h00000000, Sign? lt_signed: (in1 < in2)};
            default: out <= 32'h00000000;
        endcase
    end

endmodule
