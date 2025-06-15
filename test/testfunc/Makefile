all:
	riscv32-unknown-elf-gcc -g -O0 -nostdlib ../start.S test.c -o test
	riscv32-unknown-elf-objdump -d test > test.dump
	cp test.dump memory.dump
	python3 ../compiler.py memory.dump > memory.data

	iverilog -o sim_top_haconiwa \
	../../src/haconiwa_top.v \
	../../src/haconiwa_core.v \
	../../src/dmem_iverilog.v \
	../../src/imem_iverilog.v \
	../../src/regfile.v \
	../../src/decoder.v \
	../../src/alu.v \

	./sim_top_haconiwa


