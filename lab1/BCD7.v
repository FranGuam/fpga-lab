module BCD7(din,dout);
input [3:0] din;
output [6:0] dout;

assign dout=(din==4'h0)?7'b0111111:
            (din==4'h1)?7'b0000110:
            (din==4'h2)?7'b1011011:
            (din==4'h3)?7'b1001111:
            (din==4'h4)?7'b1100110:
            (din==4'h5)?7'b1101101:
            (din==4'h6)?7'b1111101:
            (din==4'h7)?7'b0000111:
            (din==4'h8)?7'b1111111:
            (din==4'h9)?7'b1101111:7'b0;
endmodule
