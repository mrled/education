#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    char *binstr=NULL;
    unsigned char *teststr="asdf";
    printf("buf2hex(%s, &binstr) = %s\n", 
        teststr, buf2hex(teststr, strlen(teststr)+1, &binstr));
}