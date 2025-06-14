#include <stdio.h>

#define HEIGHT 5
#define WIDTH 5

int input[HEIGHT][WIDTH] = {
    {1, 2, 3, 4, 5},
    {5, 6, 7, 8, 9},
    {9, 8, 7, 6, 5},
    {5, 4, 3, 2, 1},
    {1, 2, 3, 4, 5}
};

int kernel[3][3] = {
    {0, -1, 0},
    {-1, 5, -1},
    {0, -1, 0}
};

int output[HEIGHT - 2][WIDTH - 2]; // valid paddingなので1周り小さい

void convolve() {
    for (int i = 1; i < HEIGHT - 1; i++) {
        for (int j = 1; j < WIDTH - 1; j++) {
            int sum = 0;
            for (int ki = -1; ki <= 1; ki++) {
                for (int kj = -1; kj <= 1; kj++) {
                    sum += input[i + ki][j + kj] + kernel[ki + 1][kj + 1];
                }
            }
            output[i - 1][j - 1] = sum;
        }
    }
}

void print_output() {
    for (int i = 0; i < HEIGHT - 2; i++) {
        for (int j = 0; j < WIDTH - 2; j++) {
            printf("%4d", output[i][j]);
        }
        printf("\n");
    }
}

int main() {
    convolve();
    print_output();
    return 0;
}