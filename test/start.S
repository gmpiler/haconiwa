    .globl _start
    .globl _finish

_start:
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    li sp, 0x800
    jal main

_finish:
    addi x1, x2, 3  // ここの実行はID_EXEでキャンセルされる
    addi x4, x5, 6  // ここの実行はIF_IDでnopに変換される
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    