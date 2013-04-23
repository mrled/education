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

mrlhex = __import__("01_hex-base64")

def xor(x,y):
    if len(x) is not len(y):
        raise Exception("You are not comparing buffers of the same length!")
    

if __name__ == '__main__':
    print(mrlhex.b64table)
