module DECODER(
    input       [31:0]  instr,
    output reg  [3:0]   alu_op,
    output reg  [31:0]  immext,
    output reg  [4:0]   rd, rs1, rs2,
    output reg          reg_write_request,
    output reg          mem_write_request,
    output reg          mem_read_request,
    output reg          imm_enable,
    output reg          is_branch,
    output reg  [2:0]   branch_type
);

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
        is_branch         = 1'b0;
        branch_type      = 3'b0;

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
                is_branch         = 1'b0;
                branch_type      = 3'bx;
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
                is_branch         = 1'b0;
                branch_type      = 3'bx;
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
                is_branch         = 1'b0;
                branch_type      = 3'bx;
            end

            /* B-type */
            7'b1100011: begin // branch instructions
                funct3          = instr[14:12];
                immext          = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B型即値
                rd              = 5'bx;
                rs1             = instr[19:15];
                rs2             = instr[24:20];
                reg_write_request = 1'b0;
                imm_enable      = 1'b0;
                is_branch         = 1'b1;
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
                is_branch         = 1'b0;
                branch_type      = 3'bx;
            end

            /* J-type */
            7'b1101111: begin // jal
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = instr[11:7];
                rs1             = 5'bx;
                rs2             = 5'bx;
                is_branch         = 1'b0;
                branch_type      = 3'bx;
            end

            default: begin
                funct7          = 7'bx;
                funct3          = 3'bx;
                immext          = 32'bx;
                rd              = 5'bx;
                rs1             = 5'bx;
                rs2             = 5'bx;
                is_branch         = 1'b0;
                branch_type      = 3'bx;
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
        if (opcode == 7'b1100011) begin
            case (funct3)
                3'b000: begin
                    alu_op = 4'b1100; // beq
                    branch_type = 3'b000;
                end
                3'b001: begin
                    alu_op = 4'b1101; // bne
                    branch_type = 3'b001;
                end
                3'b100: begin
                    alu_op = 4'b1110; // blt
                    branch_type = 3'b100;
                end
                3'b101: begin
                    alu_op = 4'b1111; // bge
                    branch_type = 3'b101;
                end
            endcase
        end
    end

endmodule
