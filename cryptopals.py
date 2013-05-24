#!/usr/bin/env python3

import argparse
import base64
import string
import sys

from pdb import set_trace as strace
# now you can just run strace() anywhere you want to run pdb.set_trace()


########################################################################
## Backend libraryish functions



def safeprint(text):
    """
    Attempt to print the passed text, but if a UnicodeEncodeError is encountered, print a warning 
    and move on. This is useful when printing candidate plaintext strings, because Windows will throw
    a UnicdeEncodeError if you try to print a character it can't print or something, and your program
    will stop.
    """
    try:
        print(text)
    except UnicodeEncodeError:
        # this (usually?) only happens on Windows
        print("WARNING: Tried to print characters that could not be displayed on this terminal. Skipping...")

def debugprint(text):
    """Print the passed text if the program is being run in debug mode."""
    if CRYPTOPALS_DEBUG:
        safeprint("DEBUG: " + str(text))

# idk if these are like cheating or something because they're using the base64 module? 
def base64_to_hex(x):
    text = base64.b64decode(x.encode())
    hexstring = ""
    for character in text:
        hexstring += '{:0>2}'.format(hex(character)[2:])
    if len(hexstring)%2 is 1:
       hextring = "0"+hexstring
    return hexstring

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

def string_to_hex(text):
    hexstring = ""
    # the last character is \x00 which just terminates it, ignore that
    for char in text.encode()[0:-1]: 
        hexstring += '{:0>2}'.format(hex(char)[2:])
    if len(hexstring)%2 is 1:
       hextring = "0"+hexstring
    return hexstring

def hex_to_base64(hexstring):
    return base64.b64encode(hex_to_string(hexstring).encode())

def hexxor(x, y):
    """Do a XOR of two hex strings of the same length"""
    
    # TODO: why does this code fail with the large input from chal06? 
    if len(x) != len(y):
        raise Exception("Buffers diff lengths! x is {} but y is {}".format(
            #x, len(x), y, len(y)))
            len(x), len(y)))
        #return False
    xbin = int(x, 16)
    ybin = int(y, 16)
    xorbin = xbin^ybin
    xorhex = hex(xorbin)[2:]
    diff = len(x) - len(xorhex)
    for i in range(0, diff):
        xorhex = "0" + xorhex
    return xorhex
def strxor(x, y):
    return hexxor(string_to_hex(x), string_to_hex(y))

def char_counts(text):
    """
    Count different types of characters in a text. Useful for statistical analysis of candidate 
    plaintext.
    """
    vowels = 'aeiouAEIOU'
    consonants = 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    count={'w':0, 'v':0, 'c':0, 'o':0}
    for character in text:
        if character in string.whitespace:
            count['w'] += 1
        elif character in vowels:
            count['v'] += 1
        elif character in consonants:
            count['c'] += 1
        else:
            count['o'] += 1
    count['l'] = count['c'] + count['v']
    return count

def winnow_wordlength(text):
    """
    Return True if some text contains 1-9 letters per space, False otherwise.
    English has an average word length of about five letters.
    """
    #debugprint("+++ winnow_wordlength({})".format(text))
    count = char_counts(text)
    try:
        avg_length = count['l'] / count['w']
    except ZeroDivisionError:
        avg_length = count['l']
    if 2 < avg_length < 8:
        #debugprint("    PASSED with {}/{} letters/whitespace".format(count['l'], count['w']))
        return True
    else:
        #debugprint("    FAILED with {}/{} letters/whitespace".format(count['l'], count['w']))
        return False

def winnow_non_ascii(text):
    """
    Return False if a text contains any non-ascii (or non-printable ascii) characters; 
    True otherwise.
    """
    for character in text:
        if not 31 <= ord(character) <= 127:
            return False
    return True

def winnow_non_ascii_using_decode(text):
    """
    Return False if a text contains any non-ascii (or non-printable ascii) characters; 
    True otherwise.
    """
    isascii = True
    try:
        atext = text.encode().decode("ascii")
        for character in atext:
            #if not 31 < ord(character) < 127:
            if not 0 <= ord(character) <= 127:
                isascii = False
                break
    except UnicodeDecodeError:
        isascii = False

    return isascii

def winnow_non_ascii_orig(text):
    """
    Return False if a text contains any non-ascii (or non-printable ascii) characters; 
    True otherwise.
    """
    try:
        atext = text.encode().decode("ascii")
    except UnicodeDecodeError:
        return False
    for character in atext:
        #if not 27 < ord(character) < 128:
        if not 31 < ord(character) < 127:
            return False
    return True

def winnow_punctuation(text):
    """Return False if a text contains too many non-letter non-space characters; False otherwise."""
    #debugprint("+++ winnow_punctuation({})".format(text))
    count = char_counts(text)
    if count['o'] < len(text)/4:
    #if count['o'] < len(text)/8:
        #debugprint("    PASSED with {}/{} junk/total characters".format(count['o'], len(text)))
        return True
    else:
        #debugprint("    FAILED with {}/{} junk/total characters".format(count['o'], len(text)))
        return False

def winnow_vowel_ratio(text):
    #debugprint("+++ winnow_vowel_ratio({})".format(text))
    count = char_counts(text)
    # in English text, v/c ratio is about 38/62 i.e. 0.612
    # https://en.wikipedia.org/wiki/Letter_frequency
    try:
        vc_ratio = count['v']/count['c']
    except ZeroDivisionError:
        vc_ratio = 1
    if 0.20 < vc_ratio < 0.90:
    #if 0.50 < vc_ratio < 0.70:
    #if 0.40 < vc_ratio < 0.80:
        #debugprint("    PASSED with ratio {}".format(vc_ratio))
        return True
    else:
        #debugprint("    FAILED with ratio {}".format(vc_ratio))
        return False

def find_1char_xor_v1(hextxt):
    """Loop through all ASCII characters, XOR them against a passed hex ciphertext, 
    and print any that are good candidates for the key."""
    strtxt = hex_to_string(hextxt)
    for i in range(1, 128):
        xorchr = chr(i)
        xortxt = '{:{fill}>{width}}'.format(xorchr, fill=xorchr, width=len(strtxt)+1)
        xorhex = string_to_hex(xortxt)
        candidate = hexxor(hextxt,xorhex)
        if candidate:
            score = score_plaintext(hex_to_string(candidate))
            if score:
                safeprint("{}: {}".format(xorchr, hex_to_string(candidate)))

class SingleCharCandidate(object):
    def __init__(self, hexstring, xorchar):

        if len(hexstring)%2 == 1:
            self.hexstring = "0" + hexstring
        else:
            self.hexstring = hexstring

        if not 0 <= ord(xorchar) <= 127:
            raise Exception("Passed a xorchar that is not an ascii character.")

        self.xorchar = xorchar
        self.hex_xorchar = "{:0>2x}".format(ord(self.xorchar))

        self.length = len(self.hexstring)

        xor_hexstring = ""
        #for byte in range(0, int((len(self.hexstring)+1)/2)):
        for byte in range(0, int(len(self.hexstring)/2)):
            xor_hexstring += self.hex_xorchar
        hex_plaintext = hexxor(self.hexstring, xor_hexstring)
        self.plaintext = hex_to_string(hex_plaintext)

    def __repr__(self):
        return "xorchar: '{}'; hexstring: '{}'; plaintext: '{}'".format(
            self.xorchar, self.hexstring, self.plaintext)

def winnow_plaintexts(candidates):
    can2 = []
    for c in candidates:
        if winnow_non_ascii(c.plaintext):
            can2 += [c]

    candidates = can2

    if len(candidates) == 0:
        return False

    opt_winnowers = [winnow_punctuation,
                     winnow_vowel_ratio, 
                     winnow_wordlength,
                     lambda x: True] # the final one must be a noop lol TODO this is dumb be ashamed

    for w in opt_winnowers:
        debugprint("WINNOWING USING METHOD {}, BEGINNING WITH {} CANDIDATES".format(
                w.__name__, len(candidates)))
        can2 = []
        for c in candidates:
            if w(c.plaintext):
                can2 += [c]
        if len(can2) is 1:
            candidates = can2
            break
        elif len(can2) is 0:
            debugprint("WINNOWING METHOD {} RESULTED IN ZERO CANDIDATES, ROLLING BACK...".format(
                w.__name__))
            # ... and you don't actually have to roll back, you just have to ignore can2
        else:
            candidates = can2

    #ideally there will be only one candidate butttt
    # TODO: winnow better so there's guaranteed to be just one candidate dummy

    if len(candidates) == 0:
        return False
    elif len(candidates) > 1:
        debugprint("WINNOWING COMPLETE BUT {} CANDIDATES REMAIN".format(len(candidates)))

    return candidates[0]


def build_1char_candidates(hexstring):
    candidates = []
    for i in range(0, 128):
        candidates += [SingleCharCandidate(hexstring, chr(i))]
    return candidates

# TODO: test before next commit
def detect_1char_xor(hexes):
    candiates = []
    for h in hexes:
        candidates = build_1char_candidates(h)
    winner = winnow_plaintexts(candidates)
    return winner

def find_1char_xor(hexstring):
    """
    Take a hex ciphertext string.
    Xor it against every ASCII character.
    Do some analysis about the resulting texts.
    Get the resulting text most likely to be English.
    Return a SingleCharCandidate object.
    """

    candidates = []
    if len(hexstring)%2 is 1:
        # pad with zero so there's an even number of hex chars
        # this way my other functions like hexxor() work properly
        h = "0" + h
    strtxt = hex_to_string(hexstring)
    for i in range(0, 128):
        candidates += [SingleCharCandidate(hexstring, chr(i))]

    # Provide the winnower functions you want to use, in order
    # Winnower functions should take a single string and return True or False
    reqd_winnowers = [winnow_non_ascii,
                      lambda x: True] # the final one must be a noop lol TODO this is dumb be ashamed

    can2 = []
    for c in candidates:
        if winnow_non_ascii(c.plaintext):
            can2 += [c]

    candidates = can2
    if len(candidates) == 0:
        return False

    opt_winnowers = [winnow_punctuation,
                     winnow_vowel_ratio, 
                     winnow_wordlength,
                     lambda x: True] # the final one must be a noop lol TODO this is dumb be ashamed

    for w in opt_winnowers:
        debugprint("WINNOWING USING METHOD {}, BEGINNING WITH {} CANDIDATES".format(
                w.__name__, len(candidates)))
        can2 = []
        for c in candidates:
            if w(c.plaintext):
                can2 += [c]
        if len(can2) is 1:
            candidates = can2
            break
        elif len(can2) is 0:
            debugprint("WINNOWING METHOD RESULTED IN ZERO CANDIDATES, ROLLING BACK...")
            # ... and you don't actually have to roll back, you just have to ignore can2
        else:
            candidates = can2

    #ideally there will be only one candidate butttt
    # TODO: winnow better so there's guaranteed to be just one candidate dummy

    if len(candidates) == 0:
        return False
    elif len(candidates) > 1:
        debugprint("WINNOWING COMPLETE BUT {} CANDIDATES REMAIN".format(len(candidates)))
    return candidates[0]


def repxor(plaintext, key):
    """
    XOR plaintext with a repeating key and return the result in hex.

    Take a plaintext string (not hex) and a key. Repeat the key as many times as is necessary. Pad 
    the plaintext with chr(0x00) so that it is equal to key length (do not truncate the key if it 
    is too long, or if it is too longer after it was repeated). XOR them together. Return the result
    as a hex string.
    """
    fullkey = key
    if len(key) < len(plaintext):
        remainder = len(plaintext) - len(key)
        iterate = int(remainder/len(key))+1 #the +1 catches a remainder, if any; I cut it down later.
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
        thisbyte_hd = 0
        while j < 8:
            if bin1[j] is not bin2[j]:
                thisbyte_hd +=1
                hamming_distance += 1
            j +=1
        #debugprint("{} {}\n{} {}\n\t-- hamming distance: {}".format(
        #        chr(char1), bin1, chr(char2), bin2, thisbyte_hd))
        i +=1
    return hamming_distance

# TODO: fix with this: http://wiki.python.org/moin/BitManipulation
def hexxor_shitty(x,y):
    if len(x) is not len(y):
        raise Exception("Buffers are different lengths! x is {} but y is {}".format(len(x), len(y)))
    binx = hex_to_bin(x)
    biny = hex_to_bin(y)
    #binxor=""
    ctr=0
    for xbit in binx:
        ybit=biny[ctr]
        if xbit is ybit:
            binxor+='0'
        else:
            binxor+='1'
        ctr+=1
    print(bin_to_hex(binxor))


class MultiCharCandidate(object):
    def __init__(self, hexstring, keylen):
        self.keylen = keylen

        if int(len(hexstring)%2) != 0:
            self.hexstring = "0" + hexstring
        else:
            self.hexstring = hexstring

        self.cipherlen = len(self.hexstring)

        # -   only operate on even-length keys because two hits is one charater
        # -   only operate on keys that can divide evenly into the ciphertext b/c the plaintext 
        #     would have been padded before the XOR.
        if self.keylen%2 != 0:
            raise Exception("Cannot create a MultiCharCandidate object with an odd keylen")

        if self.cipherlen % self.keylen != 0: 
            et = "Attempted to create a MultiCharCandidate with a ciphertext of len {}".format(
                self.cipherlen)
            et += " and key of len {}, but that cipherlen doesn't divide evenly into".format(
                self.keylen)
            et += " that keylen"
            raise Exception(et)

        self.tchunksize = int(self.cipherlen/self.keylen)

        self.chunks = []
        this_chunk = ""
        for character in self.hexstring:
            this_chunk += character
            if len(this_chunk) is self.keylen:
                self.chunks += [this_chunk]
                this_chunk = ""

        hd = hamming_code_distance(self.chunks[0], self.chunks[1])
        self.hdnorm = hd/self.keylen

        # build the transposed chunks
        # you have `len(chunks)/2` many chunks, that are all `keylen/2` long
        # you'll end up with `keylen/2` many transposed chunks that are all `len(chunks)/2` long. 
        # (you divide them all by two because two hits make up one char)
        self.tchunks = []
        for index in range(0, self.keylen):
            if index%2 is 0:
                new_tchunk = ""
                for c in self.chunks:
                    new_hits = "" + c[index] + c[index+1]
                    new_tchunk += new_hits
                self.tchunks.append(new_tchunk)

        # calculate the possibilities for each chunk
        # self.tccandidates is a list
        #     each item in the list is a list of SingleCharCandidate objects
        # self.tccandidates[0] corresponds to self.tchunks[0] of course, 
        #     and it will contain 128 objects, which we'll winnow through in the next step
        self.tccandidates = []
        self.solved_all = True
        for tc in self.tchunks:
            block_candidates = build_1char_candidates(tc)
            self.tccandidates.append(block_candidates)
            # block_candidate = find_1char_xor(tc)
            # if not block_candidate:
            #     debugprint("No block candidate found for tchunk: {}".format(tc))
            #     self.solved_all = False
            # self.tchunks += [block_candidate]

        self.tcwinners = []
        self.solved_all = True
        # now winnow the plaintexts down for each tchunk
        for tcc in self.tccandidates:
            tcwin = winnow_plaintexts(tcc)
            if tcwin:
                self.tcwinners += [tcwin]
            else:
                self.tcwinners += [False]
                self.solved_all = False


        # now, if we were able to solve each of the tchunks, reassemble the plaintext. 
        if self.solved_all:
            self.plaintext = self.strxorkey = self.hexxorkey = ""
            # y axis is location WITHIN the tchunk; x axis is which tchunk it is

            tchunk_count = len(self.tchunks)
            tchunk_size  = self.tchunksize


            for i in range(0, self.tchunksize):
                for w in self.tcwinners:
                    self.plaintext += w.plaintext[i]
                    if len(self.strxorkey) < self.keylen:
                        self.strxorkey += w.xorchar
            self.hexxorkey = string_to_hex(self.strxorkey)
        else:
            self.plaintext = self.strxorkey = self.hexxorkey = False
    
        
# TODO: rewrite to be less dumb
def hamming_code_distance(string1, string2):
    """
    Compute the Hamming Code distance between two strings
    """
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
        thisbyte_hd = 0
        while j < 8:
            if bin1[j] is not bin2[j]:
                thisbyte_hd +=1
                hamming_distance += 1
            j +=1
        #debugprint("{} {}\n{} {}\n\t-- hamming distance: {}".format(
        #        chr(char1), bin1, chr(char2), bin2, thisbyte_hd))
        i +=1
    return hamming_distance


def find_multichar_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    # Remember that if we're assuming that our XOR key came from ASCII, it will have an even number 
    # of hex digits. 
    # Throughout this function and elsewhere, keylen is specificed in *hex* digits. 
    if len(hexstring)%2 is not 0:
        hexstring = "0"+hexstring

    keylenmin = 2
    keylenmax = 40
    cipherlen = len(hexstring)

    # If you don't do this, and you pass it a too-short hexstring, it'll try to compare chunk1 with
    # chunk2 in the for loop, but they'll be different lengths after a while.
    if keylenmax >= int(len(hexstring)/2):
        keylenmax = int(len(hexstring)/2)
    debugprint("min key length: {} / max key length: {} / hexstring length: {}".format(
            keylenmin, keylenmax, len(hexstring)))

    attempts = []
    for keylen in range(keylenmin, keylenmax):
        # -   only operate on even-length keys because two hits is one charater
        # -   only operate on keys that can divide evenly into the ciphertext b/c the plaintext 
        #     would have been padded before the XOR.
        if keylen%2 == 0 and cipherlen%keylen == 0: 
            attempts += [MultiCharCandidate(hexstring, keylen)]

    attempts_sorted  = sorted(attempts, key=lambda a: a.hdnorm)

    # TODO: deal with situations where there are zero or one attempts
    #       this might happen if the keylen is too constrained, or as a result of only checking for 
    #       keys that divide evenly into the ciphertext
    max_candidates = 4
    if max_candidates > len(attempts_sorted):
        max_candidates = len(attempts_sorted)
    attempts_passed_winnowing = []
    for candidate in attempts_sorted[0:max_candidates]:
        if candidate.solved_all:
            debugprint("Key: {} Plaintext: <ELIDED>".format(
                candidate.strxorkey, candidate.plaintext))
            attempts_passed_winnowing += [candidate]

    if len(attempts_passed_winnowing) == 0:
        raise Exception("FOUND NO KEYLEN CANDIDATES THAT PASSED WINNOWING.")
    elif len(attempts_passed_winnowing) > 1:
        debugprint("WE HAVE MULTIPLE KEYLEN CANDIDATES THAT PASSED WINNOWING.")

    return attempts_passed_winnowing[0].plaintext

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
    print("orig str: " + hex_to_string(exh))

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
    print(find_1char_xor(ciphertext))

def chal04():
    gist = open("3132713.gist.txt")
    hexes = [line.strip() for line in gist.readlines()]
    gist.close()
    winner = detect_1char_xor(hexes)
    print("Detected plaintext '{}'".format(winner.plaintext))
    print("From hex string '{}'".format(winner.hexstring))
    print("XOR'd against character '{}'".format(winner.xorchar))

def chal05():
    plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
    repkey = "ICE"
    solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
    print("These two strings should match:")
    print(repxor(plaintext, repkey))
    print(solution)

def chal06():
    f = open("3132752.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    hexcipher = base64_to_hex(gist)
    print(find_multichar_xor(hexcipher))

def chal06a():
    ex1="this is a test"
    ex2="wokka wokka!!!"
    print(hamming_code_distance(ex1, ex2))

def chal06b():
    ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
    print(find_multichar_xor(ciphertext))



########################################################################
## main()

CRYPTOPALS_DEBUG=False

def debug_trap(type, value, tb):
    import traceback, pdb
    traceback.print_exception(type, value, tb)
    print("EXCEPTION ENCOUNTERED. STARTING THE DEBUGGER IN POST-MORTEM MODE.")
    pdb.pm() # the debugger in post-mortem mode

class DebugAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        #print('%r %r %r' % (namespace, values, option_string))
        #setattr(namespace, self.dest, values)
        global CRYPTOPALS_DEBUG
        CRYPTOPALS_DEBUG = True
        sys.excepthook = debug_trap


if __name__=='__main__':
    argparser = argparse.ArgumentParser(description='Matasano Cryptopals Yay')
    argparser.add_argument('--debug', '-d', nargs=0, action=DebugAction,
                           help='Show debugging information')
    subparsers = argparser.add_subparsers()
    subparser_challenges = subparsers.add_parser('challenge', aliases=['c','ch','chal'], 
                                                 help="Run one of the challenge assignments directly")
    subparser_challenges.add_argument('chalnum', type=str, action='store', 
                                      help='Choose the challenge number you want to run')

    subparser_challenges.set_defaults(func=challenger)

    parsed = argparser.parse_args()
    parsed.func(parsed)
