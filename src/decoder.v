module DECODER(
    input  [31:0] instr,
    output reg [3:0]   alu_op,
    output reg [31:0]  immext,
    output reg [4:0]   rd, rs1, rs2,
    output reg         reg_write_request,
    output reg         mem_write_request,
    output reg         mem_read_request,
    output reg         imm_enable,
    output reg [2:0]   branch_type,
    output reg         is_branch, is_jal, is_jalr,
    output reg [1:0]   dec_load_width, dec_store_width,
    output reg         dec_load_sign
);
    wire [6:0] opcode = instr[6:0];
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    always @* begin
        // default init
        alu_op            = 4'd0;
        immext            = 32'd0;
        rd                = 5'd0;
        rs1               = 5'd0;
        rs2               = 5'd0;
        reg_write_request = 1'b0;
        mem_write_request = 1'b0;
        mem_read_request  = 1'b0;
        imm_enable        = 1'b0;
        is_branch         = 1'b0;
        is_jal            = 1'b0;
        is_jalr           = 1'b0;
        branch_type       = 3'd0;
        // load/store defaults
        dec_load_width    = 2'b10; // word
        dec_load_sign     = 1'b1;  // signed
        dec_store_width   = 2'b10; // word

        funct3 = instr[14:12];
        funct7 = instr[31:25];
        rd     = instr[11:7];
        rs1    = instr[19:15];
        rs2    = instr[24:20];

        case (opcode)

            // R-type
            7'b0110011: begin
                reg_write_request = 1;
                case (funct3)
                    3'b000: alu_op = (funct7==7'b0100000) ? 4'd1 : 4'd0; // sub/add
                    3'b001: alu_op = 4'd5; // sll
                    3'b010: alu_op = 4'd8; // slt
                    3'b011: alu_op = 4'd9; // sltu
                    3'b100: alu_op = 4'd4; // xor
                    3'b101: alu_op = (funct7==7'b0100000) ? 4'd7 : 4'd6; // sra/srl
                    3'b110: alu_op = 4'd3; // or
                    3'b111: alu_op = 4'd2; // and
                endcase
            end

            // I-type arithmetic
            7'b0010011: begin
                reg_write_request = 1;
                imm_enable        = 1;
                immext            = {{20{instr[31]}}, instr[31:20]};
                case (funct3)
                    3'b000: alu_op = 4'd0;  // addi
                    3'b010: alu_op = 4'd10; // slti
                    3'b011: alu_op = 4'd11; // sltiu
                    3'b111: alu_op = 4'd2;  // andi
                    3'b110: alu_op = 4'd3;  // ori
                    3'b100: alu_op = 4'd4;  // xori
                    3'b001: alu_op = 4'd5;  // slli
                    3'b101: alu_op = (funct7==7'b0100000) ? 4'd7 : 4'd6; // srli/srai
                endcase
            end

            // I-type load
            7'b0000011: begin
                reg_write_request = 1;
                mem_read_request  = 1;
                imm_enable        = 1;
                immext            = {{20{instr[31]}}, instr[31:20]};
                case (funct3)
                    3'b000: begin dec_load_width=2'b00; dec_load_sign=1; end // lb
                    3'b001: begin dec_load_width=2'b01; dec_load_sign=1; end // lh
                    3'b100: begin dec_load_width=2'b00; dec_load_sign=0; end // lbu
                    3'b101: begin dec_load_width=2'b01; dec_load_sign=0; end // lhu
                    default: begin dec_load_width=2'b10; dec_load_sign=1; end // lw
                endcase
                alu_op = 4'd0; // add for addr
            end

            // S-type store
            7'b0100011: begin
                mem_write_request = 1;
                imm_enable        = 1;
                immext            = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                case (funct3)
                    3'b000: dec_store_width=2'b00; // sb
                    3'b001: dec_store_width=2'b01; // sh
                    default: dec_store_width=2'b10; // sw
                endcase
                alu_op = 4'd0; // add for addr
            end

            // B-type branch
            7'b1100011: begin
                is_branch   = 1;
                imm_enable  = 0;
                immext      = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8],1'b0};
                case (funct3)
                    3'b000: begin alu_op=4'd12; branch_type=3'b000; end // beq
                    3'b001: begin alu_op=4'd13; branch_type=3'b001; end // bne
                    3'b100: begin alu_op=4'd14; branch_type=3'b100; end // blt
                    3'b101: begin alu_op=4'd15; branch_type=3'b101; end // bge
                    3'b110: begin alu_op=4'd9; /* reused SLTU code */ branch_type=3'b110; end // bltu
                    3'b111: begin alu_op=4'd8; /* reused SLT code */  branch_type=3'b111; end // bgeu
                endcase
            end

            // U-type
            7'b0110111: begin // LUI
                reg_write_request = 1;
                imm_enable        = 1;
                immext            = {instr[31:12],12'd0};
                alu_op            = 4'd5; // could be custom
            end
            7'b0010111: begin // AUIPC
                reg_write_request = 1;
                imm_enable        = 1;
                immext            = {instr[31:12],12'd0};
                alu_op            = 4'd0;
            end

            // J-type
            7'b1101111: begin // JAL
                reg_write_request = 1;
                imm_enable        = 1;
                is_jal            = 1;
                immext            = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21],1'b0};
                alu_op            = 4'd0;
            end
            7'b1100111: begin // JALR
                reg_write_request = 1;
                imm_enable        = 1;
                is_jalr           = 1;
                immext            = {{20{instr[31]}}, instr[31:20]};
                alu_op            = 4'd0;
            end

        endcase
    end
endmodule
