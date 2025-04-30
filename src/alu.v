module ALU(
    input [3:0] alu_op,
    input [31:0] src1,
    input [31:0] src2,
    output reg [31:0] aluout
);

always @* begin
    case (alu_op)
        4'b0000: aluout <= src1 + src2;  // add
        4'b0001: aluout <= src1 - src2;  // sub
        4'b0010: aluout <= src1 & src2;  // and
        4'b0011: aluout <= src1 | src2;  // or
        4'b0100: aluout <= src1 ^ src2;  // xor
    endcase
end

endmodule