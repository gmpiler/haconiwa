module HACONIWA_TOP(
    input           CLOCK_50_B5B, CPU_RESET_n,
    output  [31:0]  debug_pc
);

wire [31:0] pc, instr, core2mem_access_address, mem2core_read_data, core2mem_write_data;
wire core2mem_write_request;

HACONIWA_CORE hcore(
    .clk(CLOCK_50_B5B),
    .reset(!CPU_RESET_n),
    .pc(pc),
    .instr(instr),
    .core2mem_access_address(core2mem_access_address),
    .mem2core_read_data(mem2core_read_data),
    .core2mem_write_data(core2mem_write_data),
    .core2mem_write_request(core2mem_write_request)
);

IMEM imem(
    .addr(pc),
    .instr(instr)
);

DMEM dmem(
    .clk(CLOCK_50_B5B),
    .access_address(core2mem_access_address),
    .read_data(mem2core_read_data),
    .write_data(core2mem_write_data),
    .write_request(core2mem_write_request)
);

assign debug_pc = pc;

endmodule

module SIMTOP();
    reg         clk, reset;
    wire [31:0] debug_pc;

    HACONIWA_TOP htop(
        .CLOCK_50_B5B(clk),
        .CPU_RESET_n(!reset),
        .debug_pc(debug_pc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #10 reset = 1;
        #20 reset = 0;
        $dumpfile("sim_top_haconiwa.vcd");
        $dumpvars(0, htop);

        #10000
        if (htop.dmem.RAM[32'h00000FFC >> 2] == 42)
            $display("passed");
        else begin
            $display("failed: got = %0d", htop.dmem.RAM[32'h00000FFC >> 2]);
        end

        $finish;
    end
endmodule