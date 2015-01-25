#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    const char *CHALLENGE_TITLE = "Fixed XOR";
    print_cryptopals_title(CHALLENGE_TITLE);

    unsigned char *inbin=NULL, *xorbin=NULL, *outbin=NULL;
    char *hexstr=NULL, *binstr=NULL;
    size_t inbin_sz, xorbin_sz;
    /*
    char 
        *inhex  = "1c0111001f010100061a024b53535009181c",
        *xorhex = "686974207468652062756c6c277320657965",
        *outhex = "746865206b696420646f6e277420706c6179";
    */
    char 
        *inhex  = "1c0111001f010100061a024b53535009181c00",
        *xorhex = "686974207468652062756c6c27732065796500",
        *outhex = "746865206b696420646f6e277420706c617900";
    inbin_sz  = hex2buf(inhex,  &inbin);
    xorbin_sz = hex2buf(xorhex, &xorbin);
    check(inbin_sz == xorbin_sz, "Passed two unequal buffers");
    check(strncmp( (const char*) inbin, (const char*) xorbin, inbin_sz) != 0, 
        "Why is this happening");

    outbin = fixed_xor(inbin_sz, inbin, xorbin);

    buf2hex(outbin, inbin_sz, &hexstr);
    debug("output hex string: %s", hexstr);

    free(binstr);
    free(hexstr);
    printf("SUCCESS\n");
    return 0;
error:
    free(binstr);
    free(hexstr);
    printf("FAILURE\n");
    return -1;
}

