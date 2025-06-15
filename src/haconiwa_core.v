module HACONIWA_CORE(
    input               clk,
    input               reset,
    output reg  [31:0]  pc,
    input       [31:0]  instr,
    output      [31:0]  core2mem_access_address,
    input       [31:0]  mem2core_read_data,
    output      [31:0]  core2mem_write_data,
    output              core2mem_write_request,
    output      [1:0]   core2mem_width,    // 00=byte, 01=half, 10=word
    output              core2mem_sign_ext // ロード時の符号拡張制御
);

/* === Pipeline Registers === */
reg         stall, flush;

reg [31:0]  IF_ID_pc, IF_ID_instr;

reg [3:0]   ID_EXE_alu_op;
reg [2:0]   ID_EXE_branch_type;
reg [31:0]  ID_EXE_pc, next_pc, ID_EXE_immext, ID_EXE_read_reg_data1, ID_EXE_read_reg_data2;
reg [4:0]   ID_EXE_rd, ID_EXE_rs1, ID_EXE_rs2;
reg         ID_EXE_reg_write_request, ID_EXE_mem_write_request, ID_EXE_mem_read_request, ID_EXE_imm_enable, ID_EXE_is_branch, ID_EXE_is_jal, ID_EXE_is_jalr, ID_EXE_load_sign;
reg [1:0]   ID_EXE_load_width, ID_EXE_store_width;

reg [4:0]   EXE_MEM_rd;
reg [31:0]  EXE_MEM_pc, EXE_MEM_aluout, EXE_MEM_mem_write_data;
reg         EXE_MEM_reg_write_request, EXE_MEM_mem_write_request, EXE_MEM_mem_read_request, EXE_MEM_is_jal, EXE_MEM_is_jalr, EXE_MEM_load_sign;
reg [1:0]   EXE_MEM_load_width, EXE_MEM_store_width;

reg         MEM_WB_reg_write_request;
reg [4:0]   MEM_WB_rd;
reg [31:0]  MEM_WB_reg_write_data;

/* === IF Stage === */
always @* begin
    if (flush) begin
        if (ID_EXE_is_jalr) begin
            next_pc = (ID_EXE_read_reg_data1 + ID_EXE_immext) & ~32'b1;
        end else if (ID_EXE_is_jal) begin
            next_pc = ID_EXE_pc + ID_EXE_immext;
        end else begin
            next_pc = ID_EXE_pc + ID_EXE_immext;
        end
    end else begin
        next_pc = pc + 4;
    end
end

always @ (posedge clk) begin
    if (reset) begin
        pc <= 32'h0;
    end else if (!stall) begin
        pc <= next_pc;
        IF_ID_pc <= pc;
        IF_ID_instr <= (flush) ? 32'h00000013 : instr;  // flushがexeされた場合に2つ後の命令をnop化
    end
end

always @ (posedge clk) begin
    $display("pc: 0x%x, instr: 0x%x", pc, IF_ID_instr);
end

/* === ID Stage === */
wire [3:0] alu_op;
wire [31:0] immext, read_reg_data1, read_reg_data2;
wire [4:0] rd, rs1, rs2;
wire [2:0] dec_branch_type;
wire [1:0] dec_load_width, dec_store_width;
wire dec_reg_write_request, dec_mem_write_request, dec_mem_read_request, dec_imm_enable, dec_is_branch, dec_is_jal, dec_is_jalr, dec_load_sign;

DECODER dec(
    .instr(IF_ID_instr),
    .alu_op(alu_op),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .immext(immext),
    .imm_enable(dec_imm_enable),
    .reg_write_request(dec_reg_write_request),
    .mem_write_request(dec_mem_write_request),
    .mem_read_request(dec_mem_read_request),
    .branch_type(dec_branch_type),
    .is_branch(dec_is_branch),
    .is_jal(dec_is_jal),
    .is_jalr(dec_is_jalr),
    .dec_load_width(dec_load_width),
    .dec_load_sign (dec_load_sign),
    .dec_store_width(dec_store_width)
);

REGFILE regfile(
    .clk(clk),
    .read_address1(rs1),
    .read_address2(rs2),
    .read_data1(read_reg_data1),
    .read_data2(read_reg_data2),
    .write_request(MEM_WB_reg_write_request),
    .write_address(MEM_WB_rd),
    .write_data(MEM_WB_reg_write_data)
);

wire [31:0] id_fwd_src1, id_fwd_src2;
assign id_fwd_src1 = (MEM_WB_reg_write_request && MEM_WB_rd != 0 && MEM_WB_rd == rs1)
                        ? MEM_WB_reg_write_data : read_reg_data1;
assign id_fwd_src2 = (MEM_WB_reg_write_request && MEM_WB_rd != 0 && MEM_WB_rd == rs2)
                        ? MEM_WB_reg_write_data : read_reg_data2;

always @ (posedge clk) begin
    if (!stall && !flush) begin // flushがexeされた場合に既にとりこんだ1つ後の命令をnop化
        ID_EXE_pc                   <= IF_ID_pc;
        ID_EXE_alu_op               <= alu_op;
        ID_EXE_immext               <= immext;
        ID_EXE_read_reg_data1       <= id_fwd_src1;
        ID_EXE_read_reg_data2       <= id_fwd_src2;
        ID_EXE_rd                   <= rd;
        ID_EXE_rs1                  <= rs1;
        ID_EXE_rs2                  <= rs2;
        ID_EXE_reg_write_request    <= dec_reg_write_request;
        ID_EXE_mem_write_request    <= dec_mem_write_request;
        ID_EXE_mem_read_request     <= dec_mem_read_request;
        ID_EXE_imm_enable           <= dec_imm_enable;
        ID_EXE_branch_type          <= dec_branch_type;
        ID_EXE_is_branch            <= dec_is_branch;
        ID_EXE_is_jal               <= dec_is_jal;
        ID_EXE_is_jalr              <= dec_is_jalr;
        ID_EXE_load_width           <= dec_load_width;
        ID_EXE_load_sign            <= dec_load_sign;
        ID_EXE_store_width          <= dec_store_width;
    end else begin
        ID_EXE_pc                   <= 32'b0;
        ID_EXE_alu_op               <= 4'b0;
        ID_EXE_immext               <= 32'b0;
        ID_EXE_read_reg_data1       <= 32'b0;
        ID_EXE_read_reg_data2       <= 32'b0;
        ID_EXE_rd                   <= 5'b0;
        ID_EXE_rs1                  <= 5'b0;
        ID_EXE_rs2                  <= 5'b0;
        ID_EXE_reg_write_request    <= 1'b0;
        ID_EXE_mem_write_request    <= 1'b0;
        ID_EXE_mem_read_request     <= 1'b0;
        ID_EXE_imm_enable           <= 1'b0;
        ID_EXE_branch_type          <= 1'b0; 
        ID_EXE_is_branch            <= 1'b0;
        ID_EXE_is_jal               <= 1'b0;
        ID_EXE_is_jalr              <= 1'b0;
        ID_EXE_load_width           <= 2'b0;
        ID_EXE_load_sign            <= 1'b0;
        ID_EXE_store_width          <= 2'b0;
    end
end

// load-use hazard detection
wire load_use_hazard;
assign load_use_hazard = (ID_EXE_mem_read_request &&
                            ((ID_EXE_rd == rs1 && ID_EXE_rd != 0) ||
                            (ID_EXE_rd == rs2 && ID_EXE_rd != 0)));
always @* begin
    if (reset) begin
        stall = 1'b0;
    end else begin
        stall = load_use_hazard;
    end
end

/* === EXE Stage === */
wire [31:0] exe_fwd_src1, exe_fwd_src2;
assign exe_fwd_src1 = (EXE_MEM_reg_write_request && EXE_MEM_rd != 0 && EXE_MEM_rd == ID_EXE_rs1)
                    ? EXE_MEM_aluout
                    : (MEM_WB_reg_write_request && MEM_WB_rd != 0 && MEM_WB_rd == ID_EXE_rs1)
                        ? MEM_WB_reg_write_data
                        : ID_EXE_read_reg_data1;

assign exe_fwd_src2 = (EXE_MEM_reg_write_request && EXE_MEM_rd != 0 && EXE_MEM_rd == ID_EXE_rs2)
                    ? EXE_MEM_aluout
                    : (MEM_WB_reg_write_request && MEM_WB_rd != 0 && MEM_WB_rd == ID_EXE_rs2)
                        ? MEM_WB_reg_write_data
                        : ID_EXE_read_reg_data2;

wire [31:0] alu_src1, alu_src2, exe_aluout;
assign alu_src1 = exe_fwd_src1;
assign alu_src2 = ID_EXE_imm_enable ? ID_EXE_immext : exe_fwd_src2;

ALU alu(
    .alu_op(ID_EXE_alu_op),
    .src1(alu_src1),
    .src2(alu_src2),
    .aluout(exe_aluout)
);

wire branch_taken;
assign branch_taken = (ID_EXE_is_branch && (exe_aluout == 1'b1)) ? 1'b1 : 1'b0 ;
// assign branch_taken =   (ID_EXE_branch_type == 3'b000) ? (fwd_src1 == fwd_src2) :
//                         (ID_EXE_branch_type == 3'b001) ? (fwd_src1 != fwd_src2) :
//                         (ID_EXE_branch_type == 3'b100) ? (fwd_src1 < fwd_src2) :
//                         (ID_EXE_branch_type == 3'b101) ? (fwd_src1 >= fwd_src2) : 1'b0;

always @* begin
    flush = (ID_EXE_is_branch && branch_taken) || ID_EXE_is_jal || ID_EXE_is_jalr;
end

always @ (posedge clk) begin
    EXE_MEM_aluout <= exe_aluout;
    EXE_MEM_rd <= ID_EXE_rd;
    EXE_MEM_mem_write_data <= exe_fwd_src2;
    EXE_MEM_reg_write_request <= ID_EXE_reg_write_request;
    EXE_MEM_mem_write_request <= ID_EXE_mem_write_request;
    EXE_MEM_mem_read_request <= ID_EXE_mem_read_request;
    EXE_MEM_pc <= ID_EXE_pc;
    EXE_MEM_is_jal <= ID_EXE_is_jal;
    EXE_MEM_is_jalr <= ID_EXE_is_jalr;
    EXE_MEM_load_width        <= ID_EXE_load_width;
    EXE_MEM_store_width <= ID_EXE_store_width;
    EXE_MEM_load_sign         <= ID_EXE_load_sign;
end

/* === MEM Stage === */
assign core2mem_write_request = EXE_MEM_mem_write_request;
assign core2mem_access_address = EXE_MEM_aluout;
assign core2mem_write_data = EXE_MEM_mem_write_data;
assign core2mem_width    = EXE_MEM_store_width;
assign core2mem_sign_ext = EXE_MEM_load_sign;

always @ (posedge clk) begin
    MEM_WB_reg_write_request <= EXE_MEM_reg_write_request;
    MEM_WB_rd                <= EXE_MEM_rd;
    MEM_WB_reg_write_data    <= (EXE_MEM_mem_read_request) ?
        // mem_read: width/sign に応じてバイト・ハーフ・ワードを符号 or ゼロ拡張
        ((EXE_MEM_load_width == 2'b00) ?
            (EXE_MEM_load_sign
                ? {{24{mem2core_read_data[7]}},  mem2core_read_data[7:0]}   // lb
                : {24'b0,                        mem2core_read_data[7:0]})
        : (EXE_MEM_load_width == 2'b01) ?
            (EXE_MEM_load_sign
                ? {{16{mem2core_read_data[15]}}, mem2core_read_data[15:0]} // lh
                : {16'b0,                       mem2core_read_data[15:0]})
        :
            mem2core_read_data)                                          // lw
        : (EXE_MEM_is_jal || EXE_MEM_is_jalr) ?
            EXE_MEM_pc + 32'h4                                             // jal/jalr
        : EXE_MEM_aluout;                                               // その他
end


endmodule