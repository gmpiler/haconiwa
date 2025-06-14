#include "../lib/haconiwa.h"
#define HEIGHT 5
#define WIDTH 5

// int input[HEIGHT][WIDTH];
// int kernel[3][3];
// int output[HEIGHT - 2][WIDTH - 2]; // valid paddingなので1周り小さい
// int answer[3][3];

void conv(int input[5][5], int kernel[3][3], int output[3][3], int answer[3][3]) {
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

void initcheck(int input[5][5], int kernel[3][3], int output[3][3], int answer[3][3]) {
    *RESULT_ADDR = 1000;
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            *RESULT_ADDR = input[i][j];
        }
    }

    *RESULT_ADDR = 1001;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            *RESULT_ADDR = kernel[i][j];
        }
    }

    *RESULT_ADDR = 1010;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            *RESULT_ADDR = output[i][j];
        }
    }

    *RESULT_ADDR = 1011;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            *RESULT_ADDR = answer[i][j];
        }
    }
}

void check(int input[5][5], int kernel[3][3], int output[3][3], int answer[3][3]) {
    volatile int check = 0;

    for (int i = 0; i < HEIGHT - 2; i++) {
        for (int j = 0; j < WIDTH - 2; j++) {
            if ((output[i][j] - answer[i][j]) == 0) check++;
        }
    }

    *RESULT_ADDR = check;
}

void init(int input[5][5], int kernel[3][3], int output[3][3], int answer[3][3])
{
    input[0][0] = 1;
    input[0][1] = 2;
    input[0][2] = 3;
    input[0][3] = 4;
    input[0][4] = 5;
     
    input[1][0] = 5;
    input[1][1] = 6;
    input[1][2] = 7;
    input[1][3] = 8;
    input[1][4] = 9;
     
    input[2][0] = 9;
    input[2][1] = 8;
    input[2][2] = 7;
    input[2][3] = 6;
    input[2][4] = 5;
     
    input[3][0] = 5;
    input[3][1] = 4;
    input[3][2] = 3;
    input[3][3] = 2;
    input[3][4] = 1;
     
    input[4][0] = 1;
    input[4][1] = 2;
    input[4][2] = 3;
    input[4][3] = 4;
    input[4][4] = 5;

    kernel[0][0] = 0;
    kernel[0][1] = -1;
    kernel[0][2] = 0;

    kernel[1][0] = -1;
    kernel[1][1] = 5;
    kernel[1][2] = -1;

    kernel[2][0] = 0;
    kernel[2][1] = -1;
    kernel[2][2] = 0;

    output[0][0] = 0;
    output[0][1] = 0;
    output[0][2] = 0;

    output[1][0] = 0;
    output[1][1] = 0;
    output[1][2] = 0;

    output[2][0] = 0;
    output[2][1] = 0;
    output[2][2] = 0;

    answer[0][0] = 49;
    answer[0][1] = 52;
    answer[0][2] = 55;

    answer[1][0] = 55;
    answer[1][1] = 52;
    answer[1][2] = 49;

    answer[2][0] = 43;
    answer[2][1] = 40;
    answer[2][2] = 37;
}

int main() {
    *RESULT_ADDR = 999;

    int input[5][5];
    int kernel[3][3];
    int output[3][3];
    int answer[3][3];

    init(input, kernel, output, answer);
    initcheck(input, kernel, output, answer);
    conv(input, kernel, output, answer);
    check(input, kernel, output, answer);
    *RESULT_ADDR = 0xdeadcafe;

    return 0;
}
