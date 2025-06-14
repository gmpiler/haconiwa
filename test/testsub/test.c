#include "../lib/haconiwa.h"

int sub(int *x, int lim)
{
    int k;
    for (k = 1; k < lim; k++) {
        *x += k;
    }

    return *x;
}

int main(void)
{
    int ans = 0;
  
    sub(&ans, 11);
    ans++;

    *RESULT_ADDR = ans;

    return 0;
}