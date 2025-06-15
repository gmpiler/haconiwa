# haconiwa - a toy cpu project
## SPECIFICATION
## SUPPORT
R‑タイプ（レジスタ対レジスタ演算）
add （funct7=0000000,funct3=000）
sub （funct7=0100000,funct3=000）
sll （funct3=001）
srl （funct7=0000000,funct3=101）
sra （funct7=0100000,funct3=101）
slt （funct3=010）
sltu （funct3=011）

I‑タイプ（即値演算）
addi (funct3=000)
slti (funct3=010)
sltiu (funct3=011)
andi (funct3=111)
ori (funct3=110)
xori (funct3=100)
slli (funct3=001)
srli (funct7=0000000,funct3=101)
srai (funct7=0100000,funct3=101)

I‑タイプ（ロード）
lb (funct3=000)
lh (funct3=001)
lbu (funct3=100)
lhu (funct3=101)
lw (default, funct3=010)

S‑タイプ（ストア）
sb (funct3=000)
sh (funct3=001)
sw (default, funct3=010)

B‑タイプ（分岐）
beq (funct3=000)
bne (funct3=001)
blt (funct3=100)
bge (funct3=101)
bltu (funct3=110)
bgeu (funct3=111)

U‑タイプ（上位即値）
lui (opcode 0110111)
auipc (opcode 0010111)

J‑タイプ（ジャンプ／リンク）
jal (opcode 1101111)
jalr (opcode 1100111)