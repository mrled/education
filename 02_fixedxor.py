#!/usr/bin/env python3

# 2. Fixed XOR

# Write a function that takes two equal-length buffers and produces
# their XOR sum.

# The string:

#  1c0111001f010100061a024b53535009181c

# ... after hex decoding, when xor'd against:

#  686974207468652062756c6c277320657965

# ... should produce:

#  746865206b696420646f6e277420706c6179

mrlh64 = __import__("01_hex-base64")

ex1 = '1c0111001f010100061a024b53535009181c'
ex2 = '686974207468652062756c6c277320657965'
res = '746865206b696420646f6e277420706c6179'

def hexxor_shitty(x,y):
    if len(x) is not len(y):
        raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
    binx = mrlh64.hex_to_bin(x)
    biny = mrlh64.hex_to_bin(y)
    binxor=""
    ctr=0
    for xbit in binx:
        ybit=biny[ctr]
        if xbit is ybit:
            binxor+='0'
        else:
            binxor+='1'
        ctr+=1
    # print(binx)
    # print(biny)
    # print(binxor)
    print(mrlh64.bin_to_hex(binxor))

def hexxor(x, y):
    """Do a XOR of two hex strings of the same length"""
    if len(x) is not len(y):
        #raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
        return False
    xbin = int(x, 16)
    ybin = int(y, 16)
    xorbin = xbin^ybin
    #print(hex(xorbin))
    #print(str(xorbin))
    return hex(xorbin)[2:]

if __name__ == '__main__':
    print(hexxor(ex1, ex2))
