#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    print_cryptopals_title("Single-byte XOR cipher");

    char *inhex =
        "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736";
    unsigned char *inbin=NULL;
    size_t inbin_sz = hex2buf(inhex, &inbin);


    unsigned char *xordbuf=NULL;
    for (int ix=0; ix<256; ix++) {
        xordbuf = repeating_xor(inbin, inbin_sz, (unsigned char*) &ix, 1);

        printf("Iteration %i ", ix);

        if (ascii_printable_character((char)ix)) 
            printf("character '%c'\n", (char)ix);
        else
            printf("character UNPRINTABLE\n");

        if (ascii_printable_buffer( (char*)xordbuf, inbin_sz)) 
            printf("    output: %s\n", xordbuf);
        else
            printf("    output: UNPRINTABLE\n");

        free(xordbuf);
    }
}

