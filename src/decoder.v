
/*
    少なくともaddはよさそう
*/

module DECODER(
    input       [31:0]  instr,
    output reg  [3:0]   alu_op,
    output reg  [31:0]  immext,
    output reg  [4:0]   rd, rs1, rs2
);

wire [6:0] opcode = instr[6:0];
reg [6:0] funct7;
reg [2:0] funct3;

always @* begin
    case (opcode)
        /* R-type */
        7'b0110011:
        begin
            funct7  = instr[31:25];
            funct3  = instr[14:12];
            immext  = 32'bx;
            rd      = instr[11:7];
            rs1     = instr[19:15];
            rs2     = instr[24:20];
        end

        /* I-type */
        7'b0010011,
        7'b0000011,
        7'b1100011:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end

        /* S-type */
        7'b0100011:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end

        /* B-type */
        7'b1100011:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end

        /* U-type */
        7'b011011,
        7'b0010111:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end

        /* J-type */
        7'b1101111:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end

        default:
        begin
            funct7  = 7'bx;
            funct3  = 3'bx;
            immext  = 32'bx;
            rd      = 4'bx;
            rs1     = 4'bx;
            rs2     = 4'bx;
        end
    endcase
end

always @* begin
    case (funct3)
        3'b000: begin
            case (funct7)
                7'b0000000: alu_op = 4'b0000;  // add
                7'b0100000: alu_op = 4'b0001;  // sub
                default:    alu_op = 4'bx;
            endcase
        end
        3'b001: alu_op = 4'b0010;  // sll
        3'b010: alu_op = 4'b0011;  // slt
        3'b011: alu_op = 4'b0100;  // sltu
        3'b100: alu_op = 4'b0101;  // xor
        3'b101: begin
            case (funct7)
                7'b0000000: alu_op = 4'b0110;  // srl
                7'b0100000: alu_op = 4'b0111;  // sra
                default:    alu_op = 4'bx;
            endcase
        end
        3'b110: alu_op = 4'b1000;  // or
        3'b111: alu_op = 4'b1001;  // and
        default:
            alu_op = 4'bx;
    endcase
end

endmodule

// module SIM_DEC();
//     reg clk;
//     reg[31:0] instr;
//     wire[31:0] immext;
//     wire[3:0] alu_op;
//     wire[4:0] rd, rs1, rs2;

//     DECODER dec(
//         .instr(instr),
//         .alu_op(alu_op),
//         .immext(immext),
//         .rd(rd),
//         .rs1(rs1),
//         .rs2(rs2)
//     );

//     initial begin
//         clk = 0;
//         forever #10 clk = ~clk;
//     end

//     initial begin
//         $dumpfile("sim_dec.vcd");
//         $dumpvars(0, dec);
        
//         #10
//         instr = 32'b00000001000010000000100000110011;
        
//         #10 $finish;
//     end

// endmodule