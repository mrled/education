#!/usr/bin/env python3

import argparse
import base64


########################################################################
## Backend libraryish functions

def safeprint(string):
    """
    Attempt to print the passed string, but if a UnicodeEncodeError is encountered, print a warning 
    and move on. This is useful when printing candidate plaintext strings, because Windows will throw
    a UnicdeEncodeError if you try to print a character it can't print or something, and your program
    will stop.
    """
    try:
        print(string)
    except UnicodeEncodeError:
        # this usually only happens on Windows
        print("WARNING: Tried to print characters that could not be displayed on this terminal. Skipping...")

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

def hex_to_bin(hexstring):
    bs = int(hexstring, 16)
    return bs

def bin_to_hex(integer):
    return hex(integer)

def string_to_hex(string):
    hexstring = ""
    for char in string.encode()[0:-1]: # the last character os \x00 which just terminates it, ignore that
        hexstring += '{:0>2}'.format(hex(char)[2:])
    return hexstring

def hex_to_base64(hexstring):
    return base64.b64encode(hex_to_string(hexstring).encode())

def hexxor(x, y):
    """Do a XOR of two hex strings of the same length"""
    if len(x) is not len(y):
        raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
        #return False
    xbin = int(x, 16)
    ybin = int(y, 16)
    xorbin = xbin^ybin
    return hex(xorbin)[2:]
def strxor(x, y):
    return hexxor(string_to_hex(x), string_to_hex(y))

def char_counts(text):
    """
    Count different types of characters in a text. Useful for statistical analysis of candidate plaintext.
    """
    vowels = 'aeiouAEIOU'
    consonants = 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    ignoreds = ''
    count={'s':0, 'v':0, 'c':0, 'o':0}
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
            count['o'] += 1
    return count

def winnow_wordcount(text):
    """Return True if some text contains at least 3 spaces; False otherwise"""
    sentence=text.split(' ')
    #print(text)

    if len(sentence) > 4:
        return True
    else:
        return False

def winnow_junk_chars(text):
    """Return False if a text contains too many non-letter non-space characters; False otherwise."""
    count = char_counts(text)
    if count['o'] < len(text)/4:
        return True
    else:
        return False

def find_1char_xor_v1(hextxt):
    """Loop through all ASCII characters, XOR them against a passed hex ciphertext, 
    and print any that are good candidates for the key."""
    strtxt = hex_to_string(hextxt)
    for i in range(1, 128):
        xorchr = chr(i)
        xortxt = '{:{fill}>{width}}'.format(xorchr, fill=xorchr, width=len(strtxt)+1)
        xorhex = mrlh64.string_to_hex(xortxt)
        candidate = hexxor(hextxt,xorhex)
        if candidate:
            score = score_plaintext(hex_to_string(candidate))
            if score:
                safeprint("{}: {}".format(xorchr, hex_to_string(candidate)))

def find_1char_xor(hexes):
    """
    Take an array of hex ciphertext strings and find the one string in it that is XORed against 
    one ASCII character, and print them both.

    Take a hex ciphertext string, or an array of them. 
    For each passed ciphertext, loop through all ASCII characters and XOR them against the ciphertext
    Winnow each of these candidate plaintexts by doing statistical analysis on them.
    Print any that might be English. 
    """
    if type(hexes) is str:
        hexes = [hexes]
    elif type(hexes) is not list:
        raise Exception("You should have passed a list of hex strings (or a single hex string).")

    # First loop through all hexes, and generate a XOR for all ASCII characters for each hex, 
    # and cut out any that don't have at least a few words separated by spaces. 
    passed = []
    for h in hexes:
        strtxt = hex_to_string(h)
        for i in range(1, 128):
            xorchr = chr(i)
            xortxt = '{:{fill}>{width}}'.format(xorchr, fill=xorchr, width=len(strtxt)+1)
            xorhex = string_to_hex(xortxt)
            candidate = hexxor(h,xorhex)
            canstring = hex_to_string(candidate)
            if winnow_wordcount(canstring):
                p = {'hex':h, 'xorchr':xorchr, 'canstring':canstring}
                passed += [p]

    # Now apply other winnowing methods
    passed2=[]
    for p in passed:
        if winnow_junk_chars(p['canstring']):
            passed2 += [p]

    # And finally, print the winners
    for p in passed2:
        print("{}, {}, {}".format(p['hex'], p['xorchr'], p['canstring']))

def repxor(plaintext, key):
    """
    XOR plaintext with a repeating key and return the result in hex.

    Take a plaintext string (not hex) and a key. Repeat the key as many times as is necessary. Pad the 
    plaintext with chr(0x00) so that it is equal to key length (do not truncate the key if it is too long, 
    or if it is too longer after it was repeated). XOR them together. Return the result as a hex string.
    """
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

    hextxt = string_to_hex(plaintext)
    hexkey = string_to_hex(fullkey)
    bintxt = int(hextxt, 16)
    binkey = int(hexkey, 16)
    binxor = bintxt^binkey
    hexxor = hex(binxor)[2:]
    if len(hexxor)%2 is 1:
        # pad the beginning with zero so that the hexxor string has an even number of hex bits in it. 
        # useful because not only does it match the provided solution this way, it also 
        # means there are two hex digits per character so the ciphertext is decodable to ASCII
        # and it's consistent with how you'd encode plaintext.
        hexxor = "0"+hexxor
    return(hexxor)

def hamming_code_distance(string1, string2):
    """
    Compute the Hamming Code distance between two strings
    """
    MYDEBUG=False
    if len(string1) is not len(string2):
        raise Exception("Buffers are different lengths!")
    bytes1=string1.encode()
    bytes2=string2.encode()
    i = 0
    hamming_distance = 0
    while i < len(bytes1):
        char1 = bytes1[i]
        char2 = bytes2[i]
        bin1 = "{:0>8}".format(bin(char1)[2:])
        bin2 = "{:0>8}".format(bin(char2)[2:])
        j = 0
        thisbit_hd = 0
        while j < 8:
            if bin1[j] is not bin2[j]:
                thisbit_hd +=1
                hamming_distance += 1
            j +=1
        if MYDEBUG:
            print("{} {}".format(chr(char1), bin1))
            print("{} {}".format(chr(char2), bin2))
            print("                   -- hamming distance: {}".format(thisbit_hd))
        i +=1
    return hamming_distance

def hexxor_shitty(x,y):
    if len(x) is not len(y):
        raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
    binx = mrlh64.hex_to_bin(x)
    biny = mrlh64.hex_to_bin(y)
    #binxor=""
    ctr=0
    for xbit in binx:
        ybit=biny[ctr]
        if xbit is ybit:
            binxor+='0'
        else:
            binxor+='1'
        ctr+=1
    print(mrlh64.bin_to_hex(binxor))


def break_repkey_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    keylenmin = 2
    keylenmax = 40


########################################################################
## Challenge functions - one per challnge, plus maybe more for the extra credit sections

# this way I can just create a new function called chalX, and call challenger("chalX"), and it calls 
# my new function. I use this in conjuunction with argparse
def challenger(args):
    print("Running challenge {}...".format(args.chalnum))
    globals()["chal"+args.chalnum]()

def chal01():
    exh = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
    exb = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'
    print("exh:      " + exh)
    print("exb->exh: " + base64_to_hex(exb))
    print("exb:      " + str(exb))
    print("exh->exb: " + hex_to_base64(exh).decode())


def chal02():
    ex1 = '1c0111001f010100061a024b53535009181c'
    ex2 = '686974207468652062756c6c277320657965'
    res = '746865206b696420646f6e277420706c6179'
    calculated = hexxor(ex1, ex2)
    print("ex1: " + ex1)
    print("ex2: " + ex2)
    print("res: " + res)
    print("calculated result:\n     " + calculated)

def chal03():
    ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
    find_1char_xor(ciphertext)

def chal04():
    gist = open("3132713.gist.txt")
    hexes = [line.strip() for line in gist.readlines()]
    gist.close()
    find_1char_xor(hexes)

def chal05():
    plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
    repkey = "ICE"
    solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
    repxor(plaintext, repkey)
    print(solution)

def chal06():
    f = open("3132752.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    hexcipher = base64_to_hex(gist)

def chal06h():
    ex1="this is a test"
    ex2="wokka wokka!!!"
    print(hamming_code_distance(ex1, ex2))



########################################################################
## main()

if __name__=='__main__':
    argparser = argparse.ArgumentParser(description='Matasano Cryptopals Yay')
    subparsers = argparser.add_subparsers()
    subparser_challenges = subparsers.add_parser('challenge', aliases=['c','ch','chal'], 
                                                 help="Run one of the challenge assignments directly")
    subparser_challenges.add_argument('chalnum', type=str, action='store', 
                                      help='Choose the challenge number you want to run')

    subparser_challenges.set_defaults(func=challenger)

    parsed = argparser.parse_args()
    parsed.func(parsed)
