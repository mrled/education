#!/usr/bin/env python3

# Write the code to encrypt the string:

#   Burning 'em, if you ain't quick and nimble
#   I go crazy when I hear a cymbal

# Under the key "ICE", using repeating-key XOR. It should come out to:

#   0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f

# Encrypt a bunch of stuff using your repeating-key XOR function. Get a
# feel for it.

import c01_hexb64

plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
repkey = "ICE"
solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

def repxor(plaintext, key):
    """This function does what I expect, except that the solution has "2f" at the end where mine has nothing.
    Is this because I'm chopping off the key instead of padding the plaintext at the end?"""
    if len(plaintext) < len(key):
        fullkey = key[0:len(plaintext)]
    elif len(key) < len(plaintext):
        remainder = len(plaintext) - len(key)
        iterate = int(remainder/len(key))+1 # the +1 catches a remainder, if any; I cut it down later.
        fullkey=key
        for i in range(iterate):
            fullkey += key
        fullkey = fullkey[0:len(plaintext)]
    else:
        fullkey = key

    hextxt = c01_hexb64.string_to_hex(plaintext)
    hexkey = c01_hexb64.string_to_hex(fullkey)
    bintxt = int(hextxt, 16)
    binkey = int(hexkey, 16)
    binxor = bintxt^binkey
    hexxor = hex(binxor)[2:]
    if len(hexxor)%2 is 1:
        # pad the beginning with zero to match the solution & so there are two hex digits per character
        hexxor = "0"+hexxor
    print(hexxor)
    #return hex(xorbin)[2:]

if __name__=='__main__':
    repxor(plaintext, repkey)
    print(solution)
