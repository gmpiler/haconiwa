#include "../lib/haconiwa.h"

int inner(int x) {
    return x * 2;
}

int main() {
    int r = inner(10);
    *(volatile int*)RESULT_ADDR = (r == 20) ? 3333 : 4444;
    return 0;
}