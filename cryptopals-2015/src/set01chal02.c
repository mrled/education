#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    print_cryptopals_title("Fixed XOR");

    unsigned char *inbin=NULL, *xorbin=NULL, *outbin=NULL;
    char *hexstr=NULL, *binstr=NULL;
    size_t inbin_sz, xorbin_sz;
    /*
    char 
        *inhex  = "1c0111001f010100061a024b53535009181c",
        *xorhex = "686974207468652062756c6c277320657965",
        *outhex = "746865206b696420646f6e277420706c6179";
    */
    char // This is the same as the official ones except NULL-terminated
        *inhex  = "1c0111001f010100061a024b53535009181c00",
        *xorhex = "686974207468652062756c6c27732065796500",
        *outhex = "746865206b696420646f6e277420706c617900";

    inbin_sz  = hex2buf(inhex,  &inbin);
    xorbin_sz = hex2buf(xorhex, &xorbin);
    check(inbin_sz == xorbin_sz, "Passed two unequal buffers");
    check(strncmp( (const char*) inbin, (const char*) xorbin, inbin_sz) != 0, 
        "Why is this happening");

    outbin = fixed_xor(inbin_sz, inbin, xorbin);

    int ix;
    for (ix=0; ix<inbin_sz; ix++) {
        log_debug("outbin[%2i] = %2c (%s)",   ix,
            outbin[ix] ? outbin[ix] : ' ', 
            int2binstr( (int)outbin[ix], &binstr));
    }

    hexstr = buf2hex(outbin, inbin_sz, &hexstr);
    log_debug("output hex string '%s' of size %zi", hexstr, inbin_sz);

    check( strncmp(outhex, hexstr, inbin_sz) == 0, 
        "Wrong value returned from buf2hex()\n"
        "    correct:  %s\n"
        "    returned: %s", outhex, hexstr);
    printf("CORRECT!\n");

    free(binstr);
    free(hexstr);
    return 0;
error:
    free(binstr);
    free(hexstr);
    log_err("ERROR DIE UGH FUCK");
    return -1;
}

