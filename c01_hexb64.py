# challenge 01

## 1. Convert hex to base64 and back.
## 
## The string:
## 
##   49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d
## 
## should produce:
## 
##   SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t
## 
## Now use this code everywhere for the rest of the exercises. Here's a
## simple rule of thumb:
## 
##   Always operate on raw bytes, never on encoded strings. Only use hex
##   and base64 for pretty-printing.

exh = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
exb = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

import base64 

# in base64, 0=A, 1=B, etc etc, so you can just look this up like `b64[0]` to get an A. 
b64table = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
            'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
            'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
            'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/']
def b64(x, reverse=False):
    if reverse is False:
        return b64table[x]
    else:
        return b64table.index(x)
def rb64(x):
    return b64(x, reverse=True)

def hex_to_bin(hexstring):
    bs = int(hexstring, 16)
    return bs

def bin_to_hex(integer):
    return hex(integer)

def b64_to_bin(b64string):
    if type(b64string) is 'string':
        b64string = b64string.encode() # b64decode() has to work on bytes objects, not string objects
    srctext = base64.b64decode(b64string)

    # srctext is a bytes object so we can loop over it like this and get ascii
    numstr=""
    for char in srctext:
        pass

def hex_to_binstring(hexstring):
    """
    convert a string containing hex to a string containing binary.
    note that a hex string will have two hexdigits per represented char i.e. 4c in hex 
    represents ascii char 'L'.
    """
    character=""
    binstring=""
    for hexdigit in hexstring:
        character+=hexdigit
        if len(character) is 2:
            # convert string 'character' containing 2 hex digits into a string 'bit' 
            # containing 8 binary digits:
            bit = "{:0>8b}".format(int(character, 16)) 
            binstring += bit
            character=""
    return binstring

def binstring_to_hex(binstring):
    hit = ""
    hexstring = ""
    for bit in binstring:
        hit+=bit
        if len(hit) is 8:
            hexstring += hex(int(hit, 2))[2:] # [2:] because hex(7) returns 0x7; we don't want the 0x
            hit=""
    return hexstring


# idk if these are like cheating or something because they're using the base64 module? 
def base64_to_hex(x):
    string = base64.b64decode(x.encode())
    hexencoding = ""
    for c in string:
        hexencoding += hex(c)[2:]
    return hexencoding

def hex_to_string(hexstring):
    # each PAIR of hex digits represents ONE character, so grab them by twos
    character=""
    decoded=""
    for hexdigit in hexstring:
        character+=hexdigit
        if len(character) > 1:
            decoded+= chr(int(character, 16))
            character=""
    return decoded

def hex_to_base64(hexstring):
    return base64.b64encode(hex_to_string(hexstring))

def string_to_hex(string):
    hexstring = ""
    for char in string.encode()[0:-1]: # the last character os \x00 which just terminates it, ignore that
        hexstring += '{:0>2}'.format(hex(char)[2:])
    #print("hexstring: " + hexstring)
    return hexstring

def hex_to_base64_ugly(hexstring):
    """
    convert a hex string to a base64 string without using the python base64 library
    this works and it's definitely not cheating but it's pretty ugly
    """
    character=""
    binary_string=""
    b64enc=""
    for hexdigit in hexstring:
        character+=hexdigit
        if len(character) is 2:
            # convert string 'character' containing 2 hex digits into a string 'bit' 
            # containing 8 binary digits:
            bit = "{:0>8b}".format(int(character, 16)) 
            binary_string += bit
            character=""

        if len(binary_string) is 24:
            a=b64(int(binary_string[0:6], 2))
            b=b64(int(binary_string[6:12], 2))
            c=b64(int(binary_string[12:18], 2))
            d=b64(int(binary_string[18:24], 2))
            b64enc += a+b+c+d
            binary_string=""

    # if there was one extra character (i.e. two extra hex digits or 8 extra binary digits)
    if len(binary_string) is 8:
        binary_string+="0000000000000000"
        a=b64(int(binary_string[0:6], 2))
        b=b64(int(binary_string[6:12], 2))
        c="="
        d="="
        b64enc += a+b+c+d
        binary_string=""

    # if there were two extra characters (i.e. four extra hex digits or 16 extra binary digits)
    elif len(binary_string) is 16:
        binary_string+="00000000000000000000000000000000"
        a=b64(int(binary_string[0:6], 2))
        b=b64(int(binary_string[6:12], 2))
        c=b64(int(binary_string[12:18], 2))
        d="="
        b64enc += a+b+c+d
        binary_string=""

    return b64enc


if __name__=='__main__':
    
    print("exh " + exh)
    print("exb " + str(exb))
    
    #print(hex_to_base64(exh))
    print("    " + b64_to_hex(exb))
    
    exhr2 = exh + "49"
    exhr4 = exh + "4949"
    
    #print("hex to base64: " + hex_to_base64(exhr4))
    #print("exb            " + str(exb))
