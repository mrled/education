#include <stdio.h>

#include "../common/common.h"


int main(int argc, char *argv[]) {
    int ix; 
    unsigned char *buf;
    char *b64;
    size_t buf_len;

    for(ix=0; ix<argc; ix++) {
        buf_len = hex2buf(argv[ix], &buf);
        b64 = buf2b64(buf, buf_len); 
        printf("Hex '%s'\n -> B64 '%s'\n\n", argv[ix], b64);
    }


error:
    return -1;
}