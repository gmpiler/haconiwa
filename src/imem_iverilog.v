`define MEMDATA "memory.data"

module IMEM(
    input   [31:0]  addr,
    output  [31:0]  instr
);

reg [31:0]  ROM[63:0];

initial begin
    $readmemh(`MEMDATA, ROM, 0, 63);
end

assign  instr = ROM[addr[31:2]];    // pc <= pc + 32'h4;に対応

endmodule