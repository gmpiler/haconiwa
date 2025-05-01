module DMEM(
    input           clk, write_request,
    input [31:0]    mem_access_address, writedata,
    output [31:0]   readdata
);

reg [31:0] RAM[63:0];

assign readdata = RAM[mem_access_address[31:2]];

always @ (posedge clk) begin
    $display("dmemaddr: %h -> readdata: %h", mem_access_address[31:2], readdata);
    if (write_request) begin
        RAM[mem_access_address[31:2]] <= writedata;
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