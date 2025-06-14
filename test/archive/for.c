int sum(int *x, int iter)
{
    int k;
    for (k = 1; k <= iter; k++) {
        *x += k;
    }

    return *x;
}

int main(void)
{
    int x = 0;
    int ans;
    ans = sum(&x, 10);

    return 0;
}