module HACONIWA_CORE(
    input   clk,
    input   reset,
    output reg [31:0]   pc,
    input  [31:0]   instr,
    output  write_enable,
    output [31:0]   dataaddr,
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
    // $display("PC: %h", pc);
end


/* DECODE */
wire [3:0]   alu_op;
wire [31:0]  immext;
wire [4:0]   rd, rs1, rs2;
wire [31:0]  read_data1, read_data2, aluout;

// decoder
DECODER dec(
    .instr(instr),
    .alu_op(alu_op),
    .immext(immext),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2)
);

// reg
REGFILE regfile(
    .clk(clk),
    // .write_enable(),
    .write_address(rd),
    .read_address1(rs1),
    .read_address2(rs2),
    // .write_data(),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

/* EXE */
// alu
ALU alu(
    .alu_op(alu_op),
    .src1(read_data1),
    .src2(read_data2),
    .aluout(aluout)
);

/* MEM */
// mem


endmodule
