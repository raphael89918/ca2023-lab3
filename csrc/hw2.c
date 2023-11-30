#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#define array_size 6
unsigned int fp32_to_bf16(float x)
{
    float y = x;
    int *p = (int *) &y;
    unsigned int exp = *p & 0x7F800000;
    unsigned int man = *p & 0x007FFFFF;
    if (exp == 0 && man == 0) /* zero */
        return *p;
    if (exp == 0x7F800000) /* infinity or NaN */
        return *p;

    float r = x;
    int *pr = (int *) &r;
    *pr &= 0xFF800000;  /* r has the same exp as x */
    r /= 0x100;
    y = x + r;

    *p &= 0xFFFF0000;
    return *p;
}

bool BOS(float fp32_1, float fp32_2){
    unsigned int bf16_1, bf16_2, sig1, sig2, exp1, exp2, man1, man2;
    bf16_1 = fp32_to_bf16(fp32_1);
    bf16_2 = fp32_to_bf16(fp32_2);
    sig1 = bf16_1 & 0x80000000;
    sig2 = bf16_2 & 0x80000000;
    exp1 = bf16_1 & 0x7F800000;
    exp2 = bf16_2 & 0x7F800000;
    man1 = bf16_1 & 0x007F0000;
    man2 = bf16_2 & 0x007F0000;
    if (sig1 < sig2) return 1;
    else if (sig1 == 0 && sig1 == sig2 && exp1 > exp2)
        return 1;
    else if (sig1 != 0 && sig1 == sig2 && exp1 < exp2)
        return 1;
    else if (sig1 == 0 && sig1 == sig2 && exp1 == exp2 && man1 > man2)
        return 1;
    else if (sig1 != 0 && sig1 == sig2 && exp1 == exp2 && man1 < man2)
        return 1;
    else return 0;
}

void ShellSort(float array[array_size]){
    int interval = array_size / 2;
    while (interval >0){
        for(int i = interval;i<array_size;i++){
            int j = i;
            float temp = array[i];
            int Flag = BOS(array[j-interval], temp);
            while (j>= interval && Flag == 1){
                array[j] = array[j-interval];
                j = j-interval;
                Flag = BOS(array[j-interval], temp);
            }
            array[j] = temp;
        }
        interval = interval / 2;
    }
}
static inline uint32_t read_cycle(void) {
        uint32_t cycle;
            asm volatile ("rdcycle %0" : "=r" (cycle));
                return cycle;

}

int main()
{
    uint32_t start_cycle, end_cycle;
    start_cycle = read_cycle();
    float array[array_size] = {1.6,-1.5,1.4,-1.3,1.2,-1.1};
    ShellSort(array);
    /*for (int i = 0;i<array_size;i++){
        printf("%x\n",fp32_to_bf16(array[i]));
    }
    end_cycle = read_cycle();
    printf("Start Cycle: %u\n", start_cycle);
    printf("End Cycle: %u\n", end_cycle);
    printf("Cycles Elapsed: %u\n", end_cycle - start_cycle);
    */
    return 0;
}
