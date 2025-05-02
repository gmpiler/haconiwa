module ALU(
    input       [3:0]   alu_op,
    input       [31:0]  src1,
    input       [31:0]  src2,
    output reg  [31:0]  aluout
);

always @* begin
    case (alu_op)
        4'b0000,
        4'b1010:
        begin
            aluout <= src1 + src2;  // add, addi
        end
        4'b0001: aluout <= src1 - src2;  // sub
        4'b0010: aluout <= src1 & src2;  // and
        4'b0011: aluout <= src1 | src2;  // or
        4'b0100: aluout <= src1 ^ src2;  // xor
        4'b1100: aluout <= (src1 == src2) ? 32'b1 : 32'b0; // beq
        4'b1101: aluout <= (src1 != src2) ? 32'b1 : 32'b0; // bne
        4'b1110: aluout <= ($signed(src1) < $signed(src2)) ? 32'b1 : 32'b0; // blt
        4'b1111: aluout <= ($signed(src1) >= $signed(src2)) ? 32'b1 : 32'b0; // bge
    endcase
end

endmodule