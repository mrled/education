#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "../common/common.h"

main(int argc, char *argv[]) {
    char *binstr=NULL;
    uint32_t ix, shift;
    uint32_t inslice;

    #define CHARS_LEN 3
    uint32_t chars[CHARS_LEN] = {'M','a','n'};
    uint32_t shiftedchars[CHARS_LEN];

    uint32_t masks[] = {63 << 18, 63 << 12, 63 << 6, 63 << 0};
    //uint32_t mask1=0x80000000, mask32=pow(2,32)-1;
    unsigned int mask1 = 0x80000000; 
    //uint32_t mask1= pow(2,31);
    uint32_t mask6=pow(2,6) -1;
    uint32_t mask32=pow(2,32)-1;

    long dick; 
    if (argc >1) {
        for (ix=1; ix<argc; ix++) {
            dick = strtol(argv[ix], NULL, 10);
            printf("%s => %s\n", argv[ix], int2binstr(dick, &binstr));
        }
    }

    for (ix=0; ix<=5; ix++) {
        printf("%02i => %s\n", ix, int2binstr(ix, &binstr));
        //printf(" 6-bit mask << %i (%08i) => %s\n", 12, 12, "asdf");
    }

    for (ix=0, shift=3; ix<4; ix++, shift--) {
        printf(" 6-bit mask << %2i (%08i) => %s\n", shift*6, mask6<<(shift*6), int2binstr(mask6<<(shift*6), &binstr));
        //printf(" 6-bit mask << %i (%08i) => %s\n", 12, 12, "asdf");
    }

    printf(" 1-bit mask (%11"PRIu32") => %s\n", mask1,  int2binstr(mask1,  &binstr));
    printf("32-bit mask (%11"PRIu32") => %s\n", mask32, int2binstr(mask32, &binstr));

    inslice = 0;
    for (ix=0, shift=CHARS_LEN; ix<CHARS_LEN; ix++, shift--) {
        shiftedchars[ix] = chars[ix] << 8 * (shift -1);
        //mask = 255 << 8*shift;
        printf("%c (%04i)      =>  %s\n", chars[ix], (int)chars[ix], 
            int2binstr(chars[ix], &binstr));
        printf("  %c<<%-2i       =>  %s\n", chars[ix], 8*shift,
            int2binstr(shiftedchars[ix], &binstr));
        inslice = inslice | shiftedchars[ix];
        printf("  in|shift    =>  %s\n", int2binstr(inslice, &binstr));
    }

    printf("Man (inslice) =>  %s\n", int2binstr(inslice, &binstr));

    char *wps[] = { "sur", "sure", "sure.", NULL };
    for (ix=0; wps[ix]; ix++) {
        printf("'%5s'  ==b64==> '%s'\n", wps[ix], buf2b64(wps[ix], strlen(wps[ix]), &binstr));
    }

    char *wikipedia_sentence =
    "Man is distinguished, not only by his reason, but by this singular passion from "
    "other animals, which is a lust of the mind, that by a perseverance of delight "
    "in the continued and indefatigable generation of knowledge, exceeds the short "
    "vehemence of any carnal pleasure.";
    printf("Wikipedia sentence: \n%s\nBase64'd: \n%s\n", 
        wikipedia_sentence, buf2b64(wikipedia_sentence, strlen(wikipedia_sentence), &binstr));

    char *mathexstr = 
        "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d";
    unsigned char *matbuf;
    size_t matbuf_len;
    matbuf_len = hex2buf(mathexstr, &matbuf);
    check(matbuf_len >=0, "hex2buf() failed? returned length was %i", matbuf_len);

    printf("matasano hex string: \n%s\nHex'd & Base64'd: \n%s\n", 
        mathexstr, buf2b64(matbuf, matbuf_len, &binstr));
    free(matbuf);

    free(binstr);
    return 0;

error:
    return -1;
}