module DECODER(
    input       [31:0]  instr,
    output reg  [3:0]   alu_op,
    output reg  [31:0]  immext,
    output reg  [4:0]   rd, rs1, rs2,
    output reg          reg_write_request,
    output reg          mem_write_request,
    output reg          mem_read_request,
    output reg          imm_enable
);

    reg debug_isload;
    reg debug_isstore;
    wire [6:0] opcode = instr[6:0];
    reg [6:0] funct7;
    reg [2:0] funct3;

    // 初期化（デフォルト値設定）
    always @* begin
        reg_write_request = 1'b0;
        mem_write_request = 1'b0;
        mem_read_request  = 1'b0;
        imm_enable        = 1'b0;
        funct7            = 7'bx;
        funct3            = 3'bx;
        rd                = 5'bx;
        rs1               = 5'bx;
        rs2               = 5'bx;
        immext            = 32'bx;
        debug_isload = 0;
        debug_isstore = 0;

        case (opcode)
            /* R-type */
            7'b0110011: begin
                funct7          = instr[31:25];
                funct3          = instr[14:12];
                immext          = 32'bx;
                rd              = instr[11:7];
                rs1             = instr[19:15];
                rs2             = instr[24:20];
                reg_write_request = 1'b1;
                imm_enable      = 1'b0;
            end

            /* I-type */
            7'b0010011, // addi
            7'b0000011: // lw
            begin
                funct7          = 7'bx;
                funct3          = instr[14:12];
                immext          = {{20{instr[31]}}, instr[31:20]};
                rd              = instr[11:7];
                rs1             = instr[19:15];
                rs2             = 5'bx;
                reg_write_request = 1'b1;
                imm_enable      = 1'b1;
            end

            /* S-type */
            7'b0100011: // sw
            begin
                funct7          = instr[31:25];
                funct3          = instr[14:12];
                immext          = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                rd              = 5'bx;
                rs1             = instr[19:15];
                rs2             = instr[24:20];
                reg_write_request = 1'b0;
                imm_enable          = 1'b1;
                debug_isstore = 1'b1;
            end

            /* B-type */
            7'b1100011: begin // branch instructions
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = 5'bx;
                rs1             = 5'bx;
                rs2             = 5'bx;
            end

            /* U-type */
            7'b0110111,  // LUI
            7'b0010111: begin  // AUIPC
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = instr[11:7];
                rs1             = 5'bx;
                rs2             = 5'bx;
            end

            /* J-type */
            7'b1101111: begin // jal
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = instr[11:7];
                rs1             = 5'bx;
                rs2             = 5'bx;
            end

            default: begin
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = 5'bx;
                rs1             = 5'bx;
                rs2             = 5'bx;
            end
        endcase
    end

    // ALU operation decoding
    always @* begin
        case (funct3)
            3'b000: begin
                if (opcode == 7'b0110011) // R-type
                begin
                    case (funct7)
                        7'b0000000: alu_op = 4'b0000;  // add
                        7'b0100000: alu_op = 4'b0001;  // sub
                        default:    alu_op = 4'bx;
                    endcase
                end
                else if (opcode == 7'b0010011) // I-type (addi)
                begin
                    alu_op = 4'b0000;   // addi
                end
                else begin
                    alu_op = 4'bx;
                end
            end

            3'b001: alu_op = 4'b0010;  // sll
            3'b010: begin
                case (opcode)
                    7'b0000011: begin // lw
                        alu_op = 4'b0000; // addでアドレス計算
                        reg_write_request = 1;
                        mem_read_request  = 1;
                        debug_isload = 1;
                    end

                    7'b0100011: begin // sw
                        alu_op = 4'b0000;
                        mem_write_request = 1;
                    end
                    default: alu_op = 4'bx;
                endcase
            end

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
            default: alu_op = 4'bx;
        endcase
    end

endmodule


// module DECODER(
//     input       [31:0]  instr,
//     output reg  [3:0]   alu_op,
//     output reg  [31:0]  immext,
//     output reg  [4:0]   rd, rs1, rs2,
//     output reg          reg_write_request,
//     output reg          mem_write_request,
//     output reg          mem_read_request,
//     output reg          imm_enable
// );

//     wire [6:0] opcode = instr[6:0];
//     wire [2:0] funct3 = instr[14:12];
//     wire [6:0] funct7 = instr[31:25];

//     always @* begin
//         // デフォルト値の設定
//         alu_op             = 4'bxxxx;
//         immext             = 32'b0;
//         rd                 = 5'b0;
//         rs1                = 5'b0;
//         rs2                = 5'b0;
//         reg_write_request  = 1'b0;
//         mem_write_request  = 1'b0;
//         mem_read_request   = 1'b0;
//         imm_enable         = 1'b0;

//         case (opcode)
//             7'b0110011: begin // R-type
//                 rd    = instr[11:7];
//                 rs1   = instr[19:15];
//                 rs2   = instr[24:20];
//                 reg_write_request = 1;
//                 imm_enable = 0;
//                 case (funct3)
//                     3'b000: alu_op = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // sub : add
//                     3'b001: alu_op = 4'b0010; // sll
//                     3'b010: alu_op = 4'b0011; // slt
//                     3'b011: alu_op = 4'b0100; // sltu
//                     3'b100: alu_op = 4'b0101; // xor
//                     3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // sra : srl
//                     3'b110: alu_op = 4'b1000; // or
//                     3'b111: alu_op = 4'b1001; // and
//                     default: alu_op = 4'bxxxx;
//                 endcase
//             end

//             7'b0010011: begin // I-type (addi, etc.)
//                 rd    = instr[11:7];
//                 rs1   = instr[19:15];
//                 immext = {{20{instr[31]}}, instr[31:20]};
//                 reg_write_request = 1;
//                 imm_enable = 1;
//                 case (funct3)
//                     3'b000: alu_op = 4'b0000; // addi
//                     default: alu_op = 4'bxxxx;
//                 endcase
//                 $display("immext1: %h (opcode: %b)", immext, opcode);
//             end

//             7'b0000011: begin // I-type (lw)
//                 rd    = instr[11:7];
//                 rs1   = instr[19:15];
//                 immext = {{20{instr[31]}}, instr[31:20]};
//                 reg_write_request = 1;
//                 mem_read_request  = 1;
//                 imm_enable = 1;
//                 alu_op = 4'b0000; // address = rs1 + imm
//                 $display("immext1: %h (opcode: %b)", immext, opcode);
//             end

//             7'b0100011: begin // S-type (sw)
//                 rs1   = instr[19:15];
//                 rs2   = instr[24:20];
//                 immext = {{27{instr[11]}}, instr[11:7]};
//                 mem_write_request = 1;
//                 imm_enable = 1;
//                 alu_op = 4'b0000; // address = rs1 + imm
//                 $display("immext2: %h (opcode: %b)", immext, opcode);
//             end

//             7'b1100011: begin // B-type (e.g., beq)
//                 rs1   = instr[19:15];
//                 rs2   = instr[24:20];
//                 immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
//                 alu_op = 4'b1010; // 仮: 比較命令
//                 imm_enable = 1;
//             end

//             7'b0110111: begin // LUI
//                 rd = instr[11:7];
//                 immext = {instr[31:12], 12'b0};
//                 reg_write_request = 1;
//                 imm_enable = 1;
//                 alu_op = 4'b0000;
//             end

//             7'b0010111: begin // AUIPC
//                 rd = instr[11:7];
//                 immext = {instr[31:12], 12'b0};
//                 reg_write_request = 1;
//                 imm_enable = 1;
//                 alu_op = 4'b0000;
//             end

//             7'b1101111: begin // JAL
//                 rd = instr[11:7];
//                 immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
//                 reg_write_request = 1;
//                 imm_enable = 1;
//                 alu_op = 4'b0000;
//             end

//             default: begin
//                 alu_op = 4'bxxxx;
//             end
//         endcase
//     end
// endmodule
