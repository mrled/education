#include <stdio.h>

#include "../common/common.h"

int main(int argc, char *argv[]) {
    int ix; 
    char *binstr=NULL;
    unsigned char *buf=NULL;
    size_t buf_len;

    const char *CHALLENGE_TITLE = "Convert hex to base64";
    print_cryptopals_title(CHALLENGE_TITLE);

    printf("Printing arguments (if any)...\n");
    for(ix=1; ix<argc; ix++) {
        printf("Input buffer '%s' is '%lu' bytes\n", argv[ix], strlen(argv[ix]));
        buf_len = hex2buf(argv[ix], &buf);
        printf("Hex '%s'\n -> B64 '%s'\n\n", argv[ix], buf2b64(buf, buf_len, &binstr));
    }
    printf("Checking official checker sentence...\n");

    char *mathexstr = 
        "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d";
    buf_len = hex2buf(mathexstr, &buf);
    check(buf_len >=0, "hex2buf() failed? returned length was %zi", buf_len);
    printf("matasano hex string: \n%s\nHex'd & Base64'd: \n%s\n", 
        mathexstr, buf2b64(buf, buf_len, &binstr));

    free(buf);
    free(binstr);
    return 0;
error:
    free(buf);
    free(binstr);
    return -1;
}



