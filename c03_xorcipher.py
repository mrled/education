#!/usr/bin/env python3

# The hex encoded string:

#       1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736

# ... has been XOR'd against a single character. Find the key, decrypt
# the message.

# Write code to do this for you. How? Devise some method for "scoring" a
# piece of English plaintext. (Character frequency is a good metric.)
# Evaluate each output and choose the one with the best score.

import c01_hexb64 as mrlh64
import c02_fixedxor as mrlxor

ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'

def score_plaintext(text):
    vowels = 'aeiouAEIOU'
    consonants = 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    ignoreds = ''
    spaces = vcount = ccount = ocount = 0
    for char in text:
        if char in ignoreds:
            pass
        elif char is ' ':
            spaces += 1
        elif char in vowels:
            vcount += 1
        elif char in consonants:
            ccount += 1
        else:
            ocount +=1
    # if ocount > 5:
    #     return False
    # elif vcount > ccount: 
    #     return False
    # else:
    #     return vcount, ccount, ocount

    #return vcount, ccount, ocount

    sentence=text.split(' ')
    #print(text)

    if len(sentence) > 4:
        return text
    else:
        return False

def xorloop(hextxt):
    strtxt = mrlh64.hex_to_string(hextxt)
    #print("hextxt: ({})".format(hextxt))
    for i in range(1, 128):
        xorchr = chr(i)
        xortxt = '{:{fill}>{width}}'.format(xorchr, fill=xorchr, width=len(strtxt)+1)
        xorhex = mrlh64.string_to_hex(xortxt)
        candidate = mrlxor.hexxor(hextxt,xorhex)
        #print(candidate)
        if candidate:
            score = score_plaintext(mrlh64.hex_to_string(candidate))
            #print("{} score: {}".format(hex(i), score))
            if score:
                print("{}: {}".format(xorchr, mrlh64.hex_to_string(candidate)))
            # try:
            #     print("{}: {}".format(xorchr, mrlh64.hex_to_string(candidate)))
            # except UnicodeEncodeError:
            #     # this usually only happens on Windows
            #     print("Junk characters (that couldn't be displayed") 
        # if score:
        #     print("{} score: ".format(hex(i), str(score)))
        # else:
        #     print("{} FAILED SCORING".format(hex(i)))


if __name__=='__main__':
    #print("ciphertext: ({})".format(ciphertext))
    xorloop(ciphertext)
