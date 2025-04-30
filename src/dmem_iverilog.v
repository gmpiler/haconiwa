module DMEM(
    input           clk, write_enable,
    input [31:0]    dataaddr, writedata,
    output [31:0]   readdata
);

reg [31:0] RAM[63:0];

assign readdata = RAM[dataaddr[31:2]];

always @ (posedge clk)
    if (write_enable)
        RAM[dataaddr[31:2]] <= writedata;

/* データメモリの初期化(シミュレーション用) */
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        RAM[i] = 64'b0;
    end
end

endmodule