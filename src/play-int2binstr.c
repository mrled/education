#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    char *binstr=NULL;
    int ii=128;
    char cc='I';
    printf("int2binstr(%i, &binstr) = %s\n", ii, int2binstr(ii, &binstr));
    printf("int2binstr(%i, &binstr) = %s\n", (int) cc, int2binstr((int)cc, &binstr));
}