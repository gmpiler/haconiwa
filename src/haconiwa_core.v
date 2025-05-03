module HACONIWA_CORE(
    input               clk,
    input               reset,
    output reg  [31:0]  pc,
    input       [31:0]  instr,
    output      [31:0]  core2mem_access_address,
    input       [31:0]  mem2core_read_data,
    output      [31:0]  core2mem_write_data,
    output              core2mem_write_request
);

/* === Pipeline Registers === */
reg         stall, flush;

reg [31:0]  IF_ID_pc, IF_ID_instr;

reg [3:0]   ID_EXE_alu_op;
reg [2:0]   ID_EXE_branch_type;
reg [31:0]  ID_EXE_pc, next_pc, ID_EXE_immext, ID_EXE_read_reg_data1, ID_EXE_read_reg_data2;
reg [4:0]   ID_EXE_rd, ID_EXE_rs1, ID_EXE_rs2;
reg         ID_EXE_reg_write_request, ID_EXE_mem_write_request, ID_EXE_mem_read_request, ID_EXE_imm_enable, ID_EXE_is_branch;

reg [4:0]   EXE_MEM_rd;
reg [31:0]  EXE_MEM_aluout, EXE_MEM_write_data;
reg         EXE_MEM_reg_write_request, EXE_MEM_mem_write_request, EXE_MEM_mem_read_request;

reg         MEM_WB_reg_write_request;
reg [4:0]   MEM_WB_rd;
reg [31:0]  MEM_WB_reg_write_data;

/* === IF Stage === */
always @* begin
    if (flush) begin
        next_pc = ID_EXE_pc + ID_EXE_immext;
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
        IF_ID_instr <= (flush) ? 32'h00000013 : instr;
    end
end

/* === ID Stage === */
wire [3:0] alu_op;
wire [31:0] immext, read_reg_data1, read_reg_data2;
wire [4:0] rd, rs1, rs2;
wire [2:0] branch_type;
wire dec_reg_write_request, dec_mem_write_request, dec_mem_read_request, dec_imm_enable, dec_is_branch;

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
    .is_branch(is_branch),
    .branch_type(branch_type)
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
    if (!stall) begin
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
        ID_EXE_is_branch            <= is_branch;
        ID_EXE_branch_type          <= branch_type;
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
        ID_EXE_is_branch            <= 1'b0;
        ID_EXE_branch_type          <= 1'b0;
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
    flush = ID_EXE_is_branch && branch_taken;
end

always @ (posedge clk) begin
    EXE_MEM_aluout <= exe_aluout;
    EXE_MEM_rd <= ID_EXE_rd;
    EXE_MEM_write_data <= exe_fwd_src2;
    EXE_MEM_reg_write_request <= ID_EXE_reg_write_request;
    EXE_MEM_mem_write_request <= ID_EXE_mem_write_request;
    EXE_MEM_mem_read_request <= ID_EXE_mem_read_request;
end

/* === MEM Stage === */
assign core2mem_write_request = EXE_MEM_mem_write_request;
assign core2mem_access_address = EXE_MEM_aluout;
assign core2mem_write_data = EXE_MEM_write_data;

always @ (posedge clk) begin
    MEM_WB_reg_write_request <= EXE_MEM_reg_write_request;
    MEM_WB_rd <= EXE_MEM_rd;
    MEM_WB_reg_write_data <= (EXE_MEM_mem_read_request) ? mem2core_read_data : EXE_MEM_aluout;
end

endmodule