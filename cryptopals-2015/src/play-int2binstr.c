#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    char *binstr=NULL;
    unsigned int ii=95;
    unsigned char cc='I';
    printf("int2binstr(%6i, &binstr) = %s\n", ii, int2binstr(ii, &binstr));
    printf("int2binstr(%6i, &binstr) = %s\n", (int) cc, int2binstr((int)cc, &binstr));

    unsigned char *outbin = fixed_xor(1, (unsigned char*)&ii, &cc);
    printf("int2binstr(outbin, &binstr) = %s\n", int2binstr( (int)outbin[0], &binstr));

    printf("int2binstr(pow(2,4)-1, &binstr) = %s\n", int2binstr( pow(2,4) -1, &binstr));
}