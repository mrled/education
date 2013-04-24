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

# Note that I pad the plaintext with chr(0x00) at the end rather than cutting down the key to fit the plaintext
# ... this is because if I do the latter, I end up with the same result except without "2f" at the end of
# the solution. 
def repxor(plaintext, key):
    fullkey = key
    if len(key) < len(plaintext):
        remainder = len(plaintext) - len(key)
        iterate = int(remainder/len(key))+1 # the +1 catches a remainder, if any; I cut it down later.
        fullkey=key
        for i in range(iterate):
            fullkey += key

    if len(plaintext) < len(fullkey):
        remainder = len(fullkey) - len(plaintext)
        for i in range(remainder):
            plaintext += chr(0x00)


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
