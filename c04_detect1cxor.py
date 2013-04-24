#!/usr/bin/env python3

# One of the 60-character strings at:

#   https://gist.github.com/3132713

# has been encrypted by single-character XOR. Find it. (Your code from
# #3 should help.)

import c03_xorcipher
import c02_fixedxor
import c01_hexb64

def winnow_wordcount(text):
    sentence=text.split(' ')
    #print(text)

    if len(sentence) > 4:
        return True
    else:
        return False

def char_counts(text):
    vowels = 'aeiouAEIOU'
    consonants = 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    ignoreds = ''
    count={'s':0, 'v':0, 'c':0, 'o':0}
    #spaces = vcount = ccount = ocount = 0
    for char in text:
        if char in ignoreds:
            pass
        elif char is ' ':
            count['s'] += 1
        elif char in vowels:
            count['v'] += 1
        elif char in consonants:
            count['c'] += 1
        else:
            count['o'] +=1
    return count

def winnow_junk_chars(text):
    count = char_counts(text)
    if count['o'] < len(text)/8:
        return True
    else:
        return False


def loop_hexes(hexes):
    if type(hexes) is str:
        hexes = [hexes]
    elif type(hexes) is not list:
        raise Exception("You should have passed a list of hex strings (or a single hex string).")

    passed = []
    for h in hexes:

        strtxt = c01_hexb64.hex_to_string(h)
        #print("h: ({})".format(h))
        for i in range(1, 128):
            xorchr = chr(i)
            xortxt = '{:{fill}>{width}}'.format(xorchr, fill=xorchr, width=len(strtxt)+1)
            xorhex = c01_hexb64.string_to_hex(xortxt)
            candidate = c02_fixedxor.hexxor(h,xorhex)
            canstring = c01_hexb64.hex_to_string(candidate)
            if winnow_wordcount(canstring):
                #print("PASSED: {} {} {}".format(h, xorchr, canstring))
                passed += [{'hex':h, 'xorchr':xorchr, 'canstring':canstring}]
                #passed += [[h, xorchr, canstring],]

    for p in passed:
        #print("{}, {}, {}".format(p['hex'], p['xorchr'], p['canstring']))
        if winnow_junk_chars(p['canstring']):
            print("{}, {}, {}".format(p['hex'], p['xorchr'], p['canstring']))


if __name__=='__main__':
    gist = open("3132713.gist.txt")
    hexes = [line.strip() for line in gist.readlines()]
    gist.close()
    loop_hexes(hexes)
