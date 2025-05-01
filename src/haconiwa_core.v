module HACONIWA_CORE(
    input   clk,
    input   reset,
    output reg [31:0]   pc,
    input  [31:0]   instr,
    output  core2mem_write_request,
    output [31:0]   mem_access_address,
    output [31:0]   writedata,
    input  [31:0]   readdata
);

/* IF */
// pc counter
always @ (posedge clk) begin
    if (reset) begin
        pc <= 32'h0;
    end else begin
        pc <= pc + 32'h4;
    end
    $display("PC: %h, instr: %h", pc, instr);
end


/* DECODE */
wire         reg_write_request_raw, mem_read_request_raw, mem_write_request_raw;
wire [3:0]   alu_op;
wire [31:0]  immext;
wire [4:0]   rd_raw, rs1, rs2;
wire [31:0]  read_reg_data1, read_reg_data2, aluout_raw;
wire imm_enable;
reg reg_write_request;
reg mem_read_request;
reg mem_write_request;
reg [31:0] aluout, mem_write_data;
reg [4:0] reg_write_addr;

// decoder
DECODER dec(
    .instr(instr),
    .alu_op(alu_op),
    .immext(immext),
    .rd(rd_raw),
    .rs1(rs1),
    .rs2(rs2),
    .reg_write_request(reg_write_request_raw),
    .mem_write_request(mem_write_request_raw),
    .mem_read_request(mem_read_request_raw),
    .imm_enable(imm_enable)
);

// reg
wire [31:0] reg_write_data = (mem_read_request) ? readdata : aluout;

REGFILE regfile(
    .clk(clk),
    .write_request(reg_write_request),
    .write_address(reg_write_addr),
    .read_address1(rs1),
    .read_address2(rs2),
    .write_data(reg_write_data),
    .read_data1(read_reg_data1),
    .read_data2(read_reg_data2)
);

/* EXE */
wire [31:0] alu_src1, alu_src2;

assign alu_src1 = read_reg_data1;
assign alu_src2 = imm_enable ? immext : read_reg_data2;

// alu
ALU alu(
    .alu_op(alu_op),
    .src1(alu_src1),
    .src2(alu_src2),
    .aluout(aluout_raw)
);

/* WB preparation */
// latch
always @ (posedge clk) begin
    mem_read_request <= mem_read_request_raw;
    mem_write_request <= mem_write_request_raw;
    reg_write_request <= reg_write_request_raw;
    mem_write_data    <= read_reg_data2;
    aluout   <= aluout_raw;
    reg_write_addr   <= rd_raw;
end

/* MEM */
// mem
assign mem_access_address = (mem_read_request || mem_write_request) ? aluout : 32'bx;
assign core2mem_write_request = mem_write_request;
assign writedata = mem_write_data;

endmodule
