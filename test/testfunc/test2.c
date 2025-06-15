#include <stdio.h>

int func2(int *x)
{
    int ret = 0;
    int t = 1;
    ret = t + *x;
    return ret;
}

int func(int *x)
{
    int ret = 0;
    for (int k = 0; k < 10; k++) {
        ret += func2(x);
    }

    return ret;
}

int main() {
    int answer = 0;
    answer = func(&answer);
    printf("%d\n", answer);

    return 0;
}
