all:
	iverilog -o sim_top_haconiwa \
	../src/haconiwa_top.v \
	../src/haconiwa_core.v \
	../src/dmem_iverilog.v \
	../src/imem_iverilog.v \
	../src/regfile.v \
	../src/decoder.v \
	../src/alu.v \

	./sim_top_haconiwa

asm_c:
	riscv32-unknown-elf-gcc -g -O0 -nostdlib start.S for.c -o for
	riscv32-unknown-elf-objdump -d for > for.dump
