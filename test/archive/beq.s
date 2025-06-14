    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
label:
    addi x1, x0, 5
    addi x2, x0, 10
    add x3, x1, x2
    addi x4, x0, 0xF
    beq x3, x4, label
    sw x3, 4(x0)