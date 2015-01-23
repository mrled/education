#ifndef _CRYPTOMRL_COMMON_H
#define _CRYPTOMRL_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>

#include "dbg.h"

size_t hex2buf(char * hexstring, unsigned char ** outbuffer);
char * normalize_hexstring(char * hexstring);
int hit2int(char hit);
unsigned char * nhex2int(char * hexstring);

#endif