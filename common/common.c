#include "common.h"

/* Transform a hex string to a byte array that the hex string represents
 * @param hexstring a string of the form '0x12ab...' or '12:ab:...' or 
 *        '12ab...'
 * @param outbuffer a pointer which will be set to the byte array
 * @return the length of the outbuffer if successful, a negative number otherwise
 */
size_t hex2buf(char * hexstring, unsigned char ** outbuffer) {
    char *normhs;
    size_t outbuffer_len;

    normhs = normalize_hexstring(hexstring);
    check(normhs, "The string %s is not a hex string", hexstring);

    *outbuffer = nhex2int(normhs);
    check(*outbuffer, "The string %s is not a hex string", hexstring);

    outbuffer_len = strlen(normhs)/2;

    free(normhs);
    return outbuffer_len;

error:
    free(normhs);
    return -1;
}

/* Normalize a string containing a hexadecimal representation of a number
 * 
 * @param hexstring a string containing a hex representation of a number
 *
 * @return a normalized, guaranteed lower-case, null-terminated hexstring 
 *         without leading '0x' or inter-byte ':' characters. if the hexstring
 *         is invalid, return NULL. the returned pointer must be freed by the
 *         caller.
 */
char * normalize_hexstring(char * hexstring) {
    unsigned int iidx=0, oidx=0;
    char ca, cb;
    size_t hexstring_len = strlen(hexstring);
    char *hexstring_norm = (char*) malloc(sizeof(char) * hexstring_len +2);
    check_mem(hexstring_norm);

    if (hexstring[0] == '0' && hexstring[1] == 'x') {
        iidx = 2;
    }

    while (iidx < hexstring_len) {

        ca = hexstring[iidx];
        cb = hexstring[iidx +1];

        if ('A'<=ca<='F') ca = tolower(ca);
        if ('A'<=cb<='F') cb = tolower(cb);

        check((hit2int(ca) >=0 && hit2int(cb) >=0), 
            "Bad input. ca==%c, cb==%c", ca, cb);

        if (ca != ':') {
            hexstring_norm[oidx] = ca;
            hexstring_norm[oidx+1] = cb;
            oidx += 2;
            iidx += 2;
        }
        else {
            iidx++;
        }
    }
    hexstring_norm[oidx] = '\0';
    debug("Original hexstring '%s' len %zi is normalized to '%s' len %zi.",
        hexstring, hexstring_len, (char*)hexstring_norm, 
        strlen(hexstring_norm));

    return hexstring_norm;

error:
    free(hexstring_norm);
    return NULL;
}

int hit2int(char hit) {
  if (! (('0'<=hit<='9') || ('a'<=hit<='f'))) {
    fprintf(stderr, "Bad argument to hit2int(): '%c'\n", hit);
    return -1;
  }
  return ((hit) <= '9' ? (hit) - '0' : (hit) - 'a' + 10);
}

/* Convert a normalized hex string to a byte array that the hex string 
 * represents
 * 
 * @param hexstring a string with any number of pairs of hex digits, without
 *        leading '0x' or inter-byte ':' characters
 * 
 * @return a buffer strlen(hexstring)/2 bytes long containing the byte array
 *         represented by hexstring
 */
unsigned char * nhex2int(char * hexstring) {
    size_t buffer_len = strlen(hexstring) / 2;
    unsigned char *buffer = malloc(buffer_len);
    int ix;
    int ia, ib;

    for (ix=0; ix<buffer_len; ix++) {
        ia = hit2int(hexstring[2 * ix + 0]);
        ib = hit2int(hexstring[2 * ix + 1]);
        check((ia >=0 && ib >=0), "Bad input. ix==%i, ia==%c, ib==%c",
            ix, ia, ib);
        // shift ia four bits to the left, because four bits is half of one 
        // byte and ia is the first half of the byte representation.
        buffer[ix] = (ia << 4) | ib;
    }

    return buffer;
error:
    free(buffer);
    return NULL;
}

const char b64idx[] = {
    'A','B','C','D','E','F','G','H',
    'I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X',
    'Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n',
    'o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3',
    '4','5','6','7','8','9','+','/'
};


/* Return a string that contains just ones and zeroes
 * You are expected to free() *outstring when you're done with it
 * Intended to let you call it repeatedly without doing that til the end though:
 *
    char *binstr=NULL; // important! we call realloc() in int2binstr!
    #define CHARS_LEN 3
    int ix, shift, chars[CHARS_LEN] = {'M','a','n'};
    for (ix=0, shift=CHARS_LEN; ix<CHARS_LEN; ix++, shift--) {
        printf("%c (%04i)    => %s\n", chars[ix], (int)chars[ix], 
            int2binstr(chars[ix], &binstr));
        printf("    %c << %i => %s\n", chars[ix], 8*shift,
            int2binstr(chars[ix] << 8*shift, &binstr));
    }
    free(binstr);

 */ 
char *int2binstr (uint32_t num, char **outstring) {
    // this is a 32-bit number w/ 1 in the most significant place and 0 in all other places
    //uint32_t mask = pow(2,31);
    unsigned int mask = 0x80000000; 
    size_t bits = sizeof(num) * CHAR_BIT;
    int idx;
    char bit;

    *outstring = realloc(*outstring, (sizeof(char) * bits) +1);
    check_mem(*outstring);

    (*outstring)[bits] = '\0';

    for (idx = 0; idx < bits; idx++, mask = mask >> 1) {
        (*outstring)[idx] = mask&num ?'1' :'0';
    }

    return *outstring;
error:
    return NULL;
}


char *buf2b64(unsigned char *buf, size_t buf_len, char **outstring) {
    int iidx, oidx;
    char inA, inB, inC;
    uint32_t inALL;
    uint32_t outA, outB, outC, outD;
    int omaskA, omaskB, omaskC, omaskD;
    size_t ossz; 
    int padding;

    char *binstr=NULL;

    omaskA = ((int)pow(2,6)-1) << (6*3);
    omaskB = ((int)pow(2,6)-1) << (6*2);
    omaskC = ((int)pow(2,6)-1) << (6*1);
    omaskD = ((int)pow(2,6)-1) << (6*0);

    padding=0;
    if (buf_len%3 ==1) {
        padding =2;
    }
    else if (buf_len%3 ==2) {
        padding =1;
    }
    ossz = (((buf_len +padding) *4) /3);

    debug("ossz == %zi", ossz);
    *outstring = realloc(*outstring, (sizeof(char) * ossz) +1);
    check_mem(*outstring);
    (*outstring)[ossz] = '\0';

    inA=inB=inC=1;
    for (iidx=0, oidx=0; iidx<buf_len; ) {
        check(inB && inC, "Entering loop after end of input string?");
        inA = buf[iidx++];
        inB = iidx<buf_len ? buf[iidx++] : 0;
        inC = iidx<buf_len ? buf[iidx++] : 0;
        inALL = (inA<<16) | (inB<<8) | (inC<<0);

#ifdef _CRYPTOMRL_DEBUG_BUF2B64    
        debug("inA << 16 => %s", int2binstr(inA << 16, &binstr));
        debug("inB <<  8 => %s", int2binstr(inB << 8, &binstr));
        debug("inC       => %s", int2binstr(inC, &binstr));

        debug("inALL => %s", int2binstr(inALL, &binstr));
#endif

        outA = (inALL & omaskA) >> 6*3;
        outB = (inALL & omaskB) >> 6*2;
        outC = (inALL & omaskC) >> 6*1;
        outD = (inALL & omaskD) >> 6*0;

#ifdef _CRYPTOMRL_DEBUG_BUF2B64    
        debug("outA => %s", int2binstr(outA, &binstr));
        debug("outB => %s", int2binstr(outB, &binstr));
        debug("outC => %s", int2binstr(outC, &binstr));
        debug("outD => %s", int2binstr(outD, &binstr));
#endif 

        (*outstring)[oidx++] = b64idx[ outA ];
        (*outstring)[oidx++] = b64idx[ outB ];

        if (inB) (*outstring)[oidx++] = b64idx[ outC ];
        else (*outstring)[oidx++] = '=';

        if (inC)  (*outstring)[oidx++] = b64idx[ outD ];
        else (*outstring)[oidx++] = '=';
    }

    debug("*outstring: %s", *outstring);

    free(binstr);
    return *outstring;
error:
    free(binstr);
    return NULL;
}

void print_cryptopals_title(const char *title) {
    size_t title_len=strlen(title);
    int ix, divider_width=80;
    char *divider, *matatitle="MATASANO CRYPTOPALS";

    divider = malloc(sizeof(char) *divider_width +1);
    divider[divider_width] = '\0';
    for (ix=0; ix<divider_width; ix++) divider[ix] = '*';

    printf("\n\n%s\n%s\n%s\n%s\n%s\n\n",
        divider, matatitle, divider, title, divider);
}

unsigned char *fixed_xor(size_t buf_sz, unsigned char *buf1, unsigned char *buf2) {
    unsigned char *outbuf = malloc(sizeof(unsigned char) *buf_sz);
    check_mem(outbuf);
    char *binstr=NULL;
    char byte1, byte2, byteout;

    debug("Passed in buffers of length %zi", buf_sz);
    debug("buf1: %s", buf1);
    debug("buf2: %s", buf2);

    int ix;
    for (ix=0; ix<buf_sz; ix++) {
        byte1 = buf1[ix];
        byte2 = buf2[ix];
        byteout = byte2 ^ byte2;
        outbuf[ix] = byteout;

        debug("Doing A XOR on byte %i: \n"
            "     byte1 (%c) (%3i)= %s\n"
            "     byte2 (%c) (%3i)= %s\n"
            "   byteout      = %s\n", ix,
            byte1, (int) byte1, int2binstr( (int) byte1, &binstr), 
            byte2, (int) byte2, int2binstr( (int) byte2, &binstr), 
            int2binstr(byteout, &binstr));
    }

    return outbuf;
error:
    free(outbuf);
    return NULL;
}

char hexidx[] = {'1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
char *buf2hex(unsigned char *buf, size_t buf_sz, char **outstring) {
    int ix;
    char *os=*outstring;
    os = realloc(os, (buf_sz*2) +1);
    check_mem(os);
    os[buf_sz*2] = '\0';

    for (ix=0; ix<buf_sz; ix++) {
        os[ix*2 +0] = hexidx[ (buf[ix] >> 4) ];
        os[ix*2 +1] = hexidx[ (buf[ix]) ];
    }

    outstring = &os;
    return os;
error:
    free(*outstring);
    return NULL;
}

