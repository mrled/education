#ifndef _CRYPTOMRL_COMMON_H
#define _CRYPTOMRL_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>
#include <ctype.h>
#include <limits.h>

#include "dbg.h"

size_t hex2buf(char * hexstring, unsigned char ** outbuffer);
char * normalize_hexstring(char * hexstring);
int hit2int(char hit);
unsigned char * nhex2int(char * hexstring);
char *int2binstr (uint32_t num, char **outstring);
char *buf2b64(unsigned char *buf, size_t buf_len, char **outstring);
void print_cryptopals_title(const char *title);
unsigned char *fixed_xor(size_t buf_sz, unsigned char *buf1, unsigned char *buf2);
char *buf2hex(unsigned char *buf, size_t buf_sz, char **outstring);

#endif