#include "../lib/haconiwa.h"

int fib(int n) {
    // 途中経過を結果アドレスに書き込む
    *RESULT_ADDR = n;

    if (n < 2) {
        *RESULT_ADDR = n;  // 返す値も記録
        return n;
    }

    int a = fib(n - 1);
    *RESULT_ADDR = a;  // fib(n-1)戻り値

    int b = fib(n - 2);
    *RESULT_ADDR = b;  // fib(n-2)戻り値

    int ret = a + b;
    *RESULT_ADDR = ret;  // 合計値を書き込み

    return ret;
}

// ネストした関数呼び出しテスト用
int nested_test(int x) {
    *RESULT_ADDR = x;  // 呼び出し時の値

    int y = fib(x);
    *RESULT_ADDR = y;  // fibの結果を書き込み

    int z = fib(x - 1);
    *RESULT_ADDR = z;  // fib(x-1)の結果を書き込み

    int sum = y + z;
    *RESULT_ADDR = sum;  // 最終結果

    return sum;
}

int main() {
    // まずfib単体テスト
    *RESULT_ADDR = 5; 
    int res1 = fib(5);
    *RESULT_ADDR = res1;

    // ネストテスト呼び出し
    *RESULT_ADDR = 10;
    int res2 = nested_test(10);
    *RESULT_ADDR = res2;
    *RESULT_ADDR = 999;

    return 0;
}
