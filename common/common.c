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
    char *hexstring_norm = (char*) malloc(sizeof(char) * strlen(hexstring) +1);
    check_mem(hexstring_norm);

    if (hexstring[0] == '0' && hexstring[1] == 'x') {
        iidx = 2;
    }

    while (iidx < strlen(hexstring)) {

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
    debug("Original hexstring: '%s'; normalized: '%s'\n", hexstring, 
        (char*)hexstring_norm);

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
    size_t ix;
    int ia, ib;

    for (ix=0; ix<buffer_len; ix++) {
        ia = hit2int(hexstring[2 * ix + 0]);
        ib = hit2int(hexstring[2 * ix + 1]);
        check((ia >=0 && ib >=0), "Bad input");
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

/* Take a buffer and convert to base64
 */
/*
char *buf2b64(char *buf, size_t buf_len) {
    int bufctr, outctr;
    size_t outstring_len;
    char *inslice, *outstring;
    char *outstring;
    int maskA, maskB, maskC, maskD;
    unsigned long long inslicell;

    uint32_t incharA, incharB, incharC, inslice;

    maskA = 63 << 18;
    maskB = 63 << 12;
    maskC = 63 << 6;
    maskD = 63;

    outstring_len = (buf_len/3) *4;
    if (buf_len%3) outstring_len += 4;
    outstring_len +=1;
    outstring[outstring_len -1] = '\0';

    inslice = malloc(sizeof(char) *4);
    check_mem(inslice);

    outstring = malloc(sizeof(char) *outstring_len);
    check_mem(outstring);

    for (bufctr=0, outctr=0; bufctr<buf_length;) {
        incharA = bufctr<buf_length ? (unsigned char) buf[ bufctr++ ] : 0;
        incharB = bufctr<buf_length ? (unsigned char) buf[ bufctr++ ] : 0;
        incharC = bufctr<buf_length ? (unsigned char) buf[ bufctr++ ] : 0;

        inslice = (incharA << 16) & (incharB << 8) & (incharC << 0)
    }

    outctr=0;
    for (bufctr=0; bufctr<buf_len; bufctr+=3) {
        strncpy(inslice, 3, &buf[bufctr]);
        inslice[3] = '\0';

        outstring[outctr++] = b64idx[ inslice & maskA ];
        outstring[outctr++] = b64idx[ inslice & maskB ];
        outstring[outctr++] = b64idx[ inslice & maskC ];
        outstring[outctr++] = b64idx[ inslice & maskD ];
    }

    free(inslice);
    return outstring;

error:
    free(inslice);
    free(outstring);
    return NULL;
}
*/

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


char *buf2b64(char *buf, size_t buf_len, char **outstring) {
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

    debug("ossz == %i", ossz);
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

