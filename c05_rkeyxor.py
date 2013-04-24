#!/usr/bin/env python3

# Write the code to encrypt the string:

#   Burning 'em, if you ain't quick and nimble
#   I go crazy when I hear a cymbal

# Under the key "ICE", using repeating-key XOR. It should come out to:

#   0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f

# Encrypt a bunch of stuff using your repeating-key XOR function. Get a
# feel for it.

plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
repkey = "ICE"
solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

def hexxor(initial, repkey):
    if len(initial) < len(repkey):
        #raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
        return False
    xbin = int(x, 16)
    ybin = int(y, 16)
    xorbin = xbin^ybin
    #print(hex(xorbin))
    #print(str(xorbin))
    return hex(xorbin)[2:]
