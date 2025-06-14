import re
import sys

def extract_instructions(filename):
    instructions = []
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            # 行の例: "   10074:	00000013          	nop"
            # 先頭にアドレスがあり、続いて命令コード（16進数）、その後にコメント
            m = re.match(r'^\s*[0-9a-f]+:\s*([0-9a-f]{8})', line)
            if m:
                instructions.append(m.group(1))
    return instructions

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python extract_instructions.py <input_file>")
        sys.exit(1)

    filename = sys.argv[1]
    instructions = extract_instructions(filename)
    for inst in instructions:
        print(inst)