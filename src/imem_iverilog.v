`define MEMDATA "memory.data"
`define IMEM_depth 4096

module IMEM(
    input   [31:0]  addr,
    output  [31:0]  instr
);

reg [31:0]  ROM[`IMEM_depth-1:0];


initial begin
    $readmemh(`MEMDATA, ROM, 0, `IMEM_depth-1);
end

assign  instr = ROM[addr[31:2]];    // pc <= pc + 32'h4;に対応

endmodule