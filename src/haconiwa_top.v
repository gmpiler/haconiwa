module HACONIWA_TOP(
    input   CLOCK_50_B5B, CPU_RESET_n
);

wire [31:0] pc, instr, readdata, dataaddr, writedata;
wire mem_write_enable;

HACONIWA_CORE hcore(
    .clk(CLOCK_50_B5B),
    .reset(!CPU_RESET_n),
    .pc(pc),
    .instr(instr),
    .mem_write_enable(mem_write_enable),
    .dataaddr(dataaddr),
    .writedata(writedata),
    .readdata(readdata)    
);

IMEM imem(
    .addr(pc),
    .instr(instr)
);

DMEM dmem(
    .clk(CLOCK_50_B5B),
    .write_enable(mem_write_enable),
    .dataaddr(dataaddr),
    .writedata(writedata),
    .readdata(readdata)
);

endmodule

module SIMTOP();
    reg clk, reset;

    HACONIWA_TOP htop(
        .CLOCK_50_B5B(clk),
        .CPU_RESET_n(!reset)
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

        #1000 $finish;
    end
endmodule