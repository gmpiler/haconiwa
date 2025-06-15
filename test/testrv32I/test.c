#include "../lib/haconiwa.h"

void main() {
    int a, b, c;

    // ----- R-TYPE -----

    // add
    a = 1; b = 2; c = a + b;
    *RESULT_ADDR = (c == 3) ? 2 : 3;

    // sub
    a = 5; b = 2; c = a - b;
    *RESULT_ADDR = (c == 3) ? 2 : 3;

    // sll
    a = 1; b = 3; c = a << b;
    *RESULT_ADDR = (c == 8) ? 2 : 3;

    // srl
    a = 16; b = 2; c = ((unsigned)a) >> b;
    *RESULT_ADDR = (c == 4) ? 2 : 3;

    // sra
    a = -16; b = 2; c = a >> b;
    *RESULT_ADDR = (c == -4) ? 2 : 3;

    // slt
    a = 3; b = 5; c = (a < b);
    *RESULT_ADDR = (c == 1) ? 2 : 3;

    // sltu
    a = -1; b = 0; c = ((unsigned)a < (unsigned)b);
    *RESULT_ADDR = (c == 0) ? 2 : 3;

    // ----- I-TYPE（即値演算）-----

    // addi
    a = 5; c = a + 7;
    *RESULT_ADDR = (c == 12) ? 2 : 3;

    // slti
    a = 1; c = (a < 10);
    *RESULT_ADDR = (c == 1) ? 2 : 3;

    // sltiu
    a = -1; c = ((unsigned)a < (unsigned)1);
    *RESULT_ADDR = (c == 0) ? 2 : 3;

    // andi
    a = 6; c = a & 3;
    *RESULT_ADDR = (c == 2) ? 2 : 3;

    // ori
    a = 6; c = a | 3;
    *RESULT_ADDR = (c == 7) ? 2 : 3;

    // xori
    a = 6; c = a ^ 3;
    *RESULT_ADDR = (c == 5) ? 2 : 3;

    // slli
    a = 2; c = a << 2;
    *RESULT_ADDR = (c == 8) ? 2 : 3;

    // srli
    a = 16; c = ((unsigned)a) >> 2;
    *RESULT_ADDR = (c == 4) ? 2 : 3;

    // srai
    a = -16; c = a >> 2;
    *RESULT_ADDR = (c == -4) ? 2 : 3;

    // ----- I-TYPE（ロード）-----

    int mem[4] = {10, 20, 30, 40};
    c = mem[2];  // lw
    *RESULT_ADDR = (c == 30) ? 2 : 3;

    // ----- S-TYPE（ストア）-----

    mem[1] = 55;  // sw
    *RESULT_ADDR = (mem[1] == 55) ? 2 : 3;

    // ----- B-TYPE（分岐）-----

    // beq
    a = 5; b = 5;
    *RESULT_ADDR = (a == b) ? 2 : 3;

    // bne
    a = 5; b = 6;
    *RESULT_ADDR = (a != b) ? 2 : 3;

    // blt
    a = 2; b = 5;
    *RESULT_ADDR = (a < b) ? 2 : 3;

    // bge
    a = 5; b = 2;
    *RESULT_ADDR = (a >= b) ? 2 : 3;

    // bltu
    a = 0; b = -1;
    *RESULT_ADDR = ((unsigned)a < (unsigned)b) ? 2 : 3;

    // bgeu
    a = -1; b = 0;
    *RESULT_ADDR = ((unsigned)a >= (unsigned)b) ? 2 : 3;

    // ----- U-TYPE -----

    // lui: 上位20ビットが使われるので、bitシフトで代替
    c = 0x12345 << 12;
    *RESULT_ADDR = (c == 0x12345000) ? 2 : 3;

    // auipc: 現在の位置+即値（擬似的にチェック）
    int pc = (int)&&label;
    c = pc + (1 << 12);
label:
    *RESULT_ADDR = ((c - pc) == 0x1000) ? 2 : 3;

    // ----- J-TYPE -----

    // jal (関数ジャンプと戻りを使って擬似テスト)
    int val = 0;
    goto jump_point;
return_point:
    *RESULT_ADDR = (val == 1234) ? 2 : 3;
    goto end;

jump_point:
    val = 1234;
    goto return_point;

end:

    return 0;
}
