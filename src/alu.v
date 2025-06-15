module ALU(
    input  [3:0]  alu_op,
    input  [31:0] src1,
    input  [31:0] src2,
    output reg [31:0] aluout
);
    // ALU operation codes
    localparam ADD    = 4'd0;
    localparam SUB    = 4'd1;
    localparam AND    = 4'd2;
    localparam OR     = 4'd3;
    localparam XOR    = 4'd4;
    localparam SLL    = 4'd5;
    localparam SRL    = 4'd6;
    localparam SRA    = 4'd7;
    localparam SLT    = 4'd8;
    localparam SLTU   = 4'd9;
    localparam SLTI   = 4'd10;
    localparam SLTIU  = 4'd11;
    localparam BEQ    = 4'd12;
    localparam BNE    = 4'd13;
    localparam BLT    = 4'd14;
    localparam BGE    = 4'd15;
    // Note: new codes for BLTU/BGEU could be assigned if needed beyond 16 ops.

    always @* begin
        case (alu_op)
            ADD:    aluout = src1 + src2;
            SUB:    aluout = src1 - src2;
            AND:    aluout = src1 & src2;
            OR:     aluout = src1 | src2;
            XOR:    aluout = src1 ^ src2;
            SLL:    aluout = src1 << src2[4:0];
            SRL:    aluout = src1 >> src2[4:0];
            SRA:    aluout = $signed(src1) >>> src2[4:0];
            SLT:    aluout = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;
            SLTU:   aluout = (src1 < src2) ? 32'd1 : 32'd0;
            SLTI:   aluout = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;
            SLTIU:  aluout = (src1 < src2) ? 32'd1 : 32'd0;
            BEQ:    aluout = (src1 == src2) ? 32'd1 : 32'd0;
            BNE:    aluout = (src1 != src2) ? 32'd1 : 32'd0;
            BLT:    aluout = ($signed(src1) < $signed(src2)) ? 32'd1 : 32'd0;
            BGE:    aluout = ($signed(src1) >= $signed(src2)) ? 32'd1 : 32'd0;
            default:aluout = 32'd0;
        endcase
    end
endmodule