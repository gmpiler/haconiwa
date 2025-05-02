module DMEM(
    input           clk, write_request,
    input   [31:0]  access_address, write_data,
    output  [31:0]  read_data
);

reg [31:0] RAM[63:0];

assign read_data = RAM[access_address[31:2]];

always @ (posedge clk) begin
    if (write_request) begin
        RAM[access_address[31:2]] <= write_data;
    end
end

/* データメモリの初期化(シミュレーション用) */
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        RAM[i] = 64'b0;
    end
end

endmodule