#include "../lib/haconiwa.h"

int fib(int n) {
    if (n <= 1) return n;
    return fib(n-1) + fib(n-2);
}

int main(void) {
    int n = 10;
    int result = fib(n);
    *RESULT_ADDR = result;
    return 0;
}