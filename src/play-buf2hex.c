#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    char *binstr=NULL;
    unsigned char *teststr= (unsigned char*)"asdf";
    size_t teststr_len = strlen( (const char*)teststr ) +1;
    printf("buf2hex(%s, &binstr) = %s\n", 
        teststr, buf2hex(teststr, teststr_len, &binstr));
}