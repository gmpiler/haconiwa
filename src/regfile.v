module REGFILE(
    input clk,
    input write_enable,
    input   [4:0] write_address,
    input   [4:0] read_address1,
    input   [4:0] read_address2,
    input  [31:0] write_data,
    output  [31:0] read_data1,
    output  [31:0] read_data2
);

reg [31:0] register_file [31:0];

// always @ (posedge clk) begin
//     if (write_enable) register_file[write_address] <= write_data;
// end

/* レジスタの初期化(シミュレーション用) */
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        register_file[i] = 32'b0;
    end
end

assign read_data1 = (read_address1 != 0) ? register_file[read_address1] : 0;
assign read_data2 = (read_address2 != 0) ? register_file[read_address2] : 0;

endmodule