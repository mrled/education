#!/usr/bin/env python3

import base64
import string
import sys

from pdb import set_trace as strace

CRYPTOPALS_DEBUG = True

def safeprint(text):
    try:
        print(text)
    except UnicodeEncodeError:
        # this (usually?) only happens on Windows
        print("WARNING: Tried to print characters that could not be displayed on this terminal. Skipping...")

def debugprint(text):
    """Print the passed text if the program is being run in debug mode."""
    if CRYPTOPALS_DEBUG:
        safeprint("DEBUG: " + str(text))

def debug_trap(type, value, tb):
    import traceback, pdb
    traceback.print_exception(type, value, tb)
    print("EXCEPTION ENCOUNTERED. STARTING THE DEBUGGER IN POST-MORTEM MODE.")
    pdb.pm() # the debugger in post-mortem mode
    sys.excepthook = debug_trap


def hexxor(x, y):
    """Do a XOR of two hex strings of the same length"""
    
    if len(x) != len(y):
        raise Exception("Buffers diff lengths! x is {} but y is {}".format(len(x), len(y)))
    xbin = int(x, 16)
    ybin = int(y, 16)
    xorbin = xbin^ybin
    xorhex = hex(xorbin)[2:]
    diff = len(x) - len(xorhex)
    for i in range(0, diff):
        xorhex = "0" + xorhex
    return xorhex

def string_to_hex(text):
    hexstring = ""
    for char in text.encode():
        hexstring += '{:0>2}'.format(hex(char)[2:])
    if len(hexstring)%2 is 1:
       hextring = "0"+hexstring
    return hexstring

def base64_to_hex(x):
    text = base64.b64decode(x.encode())
    hexstring = ""
    for character in text:
        hexstring += '{:0>2}'.format(hex(character)[2:])
    if len(hexstring)%2 is 1:
       hextring = "0"+hexstring
    return hexstring

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

def hex_to_string(hexstring):
    # each PAIR of hex digits represents ONE character, so grab them by twos
    character=""
    decoded=""
    for i in range(0, len(hexstring), 2):
        decoded += chr(int(hexstring[i:i+2], 16))
    return decoded



def winnow_noop(candidate):
    # this is dumb I know, but the final winnow function must be a noop like this b/c of
    # how I set up my loop. 
    # TODO: revisit this! 
    return True

def winnow_nonascii(candidate):
    if candidate.nonascii > 0:
        return False
    else:
        return True

def winnow_wordlength(candidate):
    try:
        avg_length = candidate.letters / candidate.whitespace
    except ZeroDivisionError:
        avg_length = candidate.letters
    if 2 < avg_length < 8:
        return True
    else:
        return False

def winnow_punctuation(candidate):
    if candidate.punctuation < candidate.allcharacters/12:
        return True
    else:
        return False

# TODO: you won't get a ratio of 0.00-1.00 by dividing vowels/consonants. fix!
def winnow_vowel_ratio(candidate):
    try:
        vc_ratio = candidate.vowels / candidate.consonants
    except ZeroDivisionError:
        vc_ratio = 1
    if 0.20 < vc_ratio < 0.90:
        return True
    else:
        return False


class SingleCharCandidate(object):
    def __init__(self, hexstring, xorchar):

        if len(hexstring)%2 == 1:
            self.hexstring = "0" + hexstring
        else:
            self.hexstring = hexstring

        #if not 0 <= ord(xorchar) <= 127:
        #    raise Exception("Passed a xorchar that is not an ascii character.")

        self.xorchar = xorchar
        self.hex_xorchar = "{:0>2x}".format(ord(self.xorchar))

        self.length = len(self.hexstring)

        xor_hexstring = ""
        #for byte in range(0, int((len(self.hexstring)+1)/2)):
        for byte in range(0, int(len(self.hexstring)/2)):
            xor_hexstring += self.hex_xorchar
        hex_plaintext = hexxor(self.hexstring, xor_hexstring)
        self.plaintext = hex_to_string(hex_plaintext)

        self.whitespace = 0
        self.vowels = 0
        self.consonants = 0
        self.digits = 0
        self.nonascii = 0
        self.punctuation = 0
        self.letters = 0 #includes digits
        self.allcharacters = len(self.plaintext)
        for character in self.plaintext:
            if not 31 <= ord(character) <= 127:
                self.nonascii += 1
            elif character in string.whitespace:
                self.whitespace += 1
            elif character in 'aeiouAEIOU':
                self.vowels += 1
            elif character in 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ':
                self.consonants += 1
            elif character in '0123456789':
                self.digits += 1
            else:
                self.punctuation += 1
        self.letters = self.consonants + self.vowels + self.digits

    def __repr__(self):
        return "xorchar: '{}'; hexstring: '{}'; plaintext: '{}'".format(
            self.xorchar, self.hexstring, self.plaintext)

    @classmethod
    def generate_ascii_candidates(self, hexstring):
        candidates = []
        for i in range(0, 256):
            candidates += [SingleCharCandidate(hexstring, chr(i))]
        return candidates


class TchunkCandidateSet(object):
    def __init__(self, text):
        self.text = text

        # calculate the possibilities for this chunk
        self.candidates = SingleCharCandidate.generate_ascii_candidates(self.text)

        self.solved = True
        # now winnow the plaintexts down for each tchunk
        # TODO: note that right now this may have several winners! make sure to handle that elsewhere
        #debugprint("Winnowing candidate: {}".format(text))


        self.winners = [c for c in self.candidates if winnow_nonascii(c)]
        if len(self.winners) == 0:
            self.solved = False
        else:
            opt_winnowers = [winnow_punctuation,
                             winnow_vowel_ratio, 
                             winnow_wordlength,
                             winnow_noop]

            for w in opt_winnowers:
                debugprint("WINNOWING USING METHOD {}, BEGINNING WITH {} CANDIDATES".format(
                        w.__name__, len(self.winners)))
                can2 = [ c for c in self.winners if w(c) ]
                if len(can2) > 0:
                    self.winners = can2
                if len(can2) == 1:
                    break
        
            #ideally there will be only one candidate butttt
            # todo: winnow better so there's guaranteed to be just one candidate dummy
        
        if len(self.winners) == 0:
            self.solved = False
            debugprint("Candidate winners: NONE")
        else:
            debugprint("Candidate winners:")
            for w in self.winners:
                debugprint(w.plaintext)


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
        # (you divide all of those by two because two hits make up one char)
        self.tchunks = []
        self.solved_all = True
        for index in range(0, self.keylen, 2):
            new_tchunk_text = ""
            for c in self.chunks:
                new_hits = "" + c[index] + c[index+1]
                new_tchunk_text += new_hits
            new_tchunk = TchunkCandidateSet(new_tchunk_text)
            self.tchunks.append(new_tchunk)
            if not new_tchunk.solved:
                self.solved_all = False

        self.plaintext = self.strxorkey = self.hexxorkey = ""
        tchunk_count = len(self.tchunks)

        for i in range(0, self.tchunksize):
            for tc in self.tchunks:
                newpt = newxc = '_' # a temp value that only gets used if there was no winner
                if tc.solved:
                    newpt = tc.winners[0].plaintext[i]
                    newxc = tc.winners[0].xorchar
                self.plaintext += newpt
                self.strxorkey += newxc


def find_multichar_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    # Remember that if we're assuming that our XOR key came from ASCII, it will have an even number 
    # of hex digits. 
    # Throughout this function and elsewhere, keylen is specificed in *hex* digits. 
    if len(hexstring)%2 is not 0:
        hexstring = "0"+hexstring

    #keylenmin = 2
    #keylenmax = 40
    keylenmin = 18
    keylenmax = 22
    cipherlen = len(hexstring)

    # If you don't do this, and you pass it a too-short hexstring, it'll try to compare chunk1 with
    # chunk2 in the for loop, but they'll be different lengths after a while.
    if keylenmax >= int(len(hexstring)/2):
        keylenmax = int(len(hexstring)/2)
    debugprint("min key length: {} / max key length: {} / hexstring length: {}".format(
        keylenmin, keylenmax, len(hexstring)))

    attempts = []
    for keylen in range(keylenmin, keylenmax, 2):
        # -   only operate on even-length keys because two hits is one charater
        # -   only operate on keys that can divide evenly into the ciphertext b/c the plaintext 
        #     would have been padded before the XOR.
        # NOTE: for our chal06, there are only *3* keylens that will pass this test: 
        #     2 (1 ascii char), 4 (2 ascii chars), 8 (4 ascii chars).
        #     cipherlen for chal06 is 5752 and 5752/8==719, a prime number.
        if cipherlen%keylen == 0: 
            debugprint("Attempting a keylen of {}".format(keylen))
            attempts += [MultiCharCandidate(hexstring, keylen)]

    attempts_sorted  = sorted(attempts, key=lambda a: a.hdnorm)
    return attempts_sorted[0]

def repxor(plaintext, basekey):
    """
    XOR plaintext with a repeating key and return the result in hex.

    Take a plaintext string (not hex) and a key. Repeat the key as many times as is necessary. Pad 
    the plaintext with chr(0x00) so that it is equal to key length (do not truncate the key if it 
    is too long, or if it is too longer after it was repeated). XOR them together. Return the result
    as a hex string.
    """
    key = basekey
    while len(key) < len(plaintext):
        key += basekey
    while len(plaintext) < len(key):
        plaintext += (chr(0x00))

    hextxt = string_to_hex(plaintext)
    hexkey = string_to_hex(key)
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



def gist_ciphertext():
    f = open("3132752.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    return base64_to_hex(gist)

def ex3_ciphertext():
    return '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'

def mytest_ciphertext():
    # the length of this string is exactly 310
    plaintext = 'To convert data to PEM printable encoding, the first byte is placed in the most significant eight bits of a 24-bit buffer, the next in the middle eight, and the third in the least significant eight bits. If there are fewer than three bytes left to encode (or in total), the remaining buffer bits will be zero..'
    key = 'abcdefghij'
    ciphertext = repxor(plaintext, key)
    print("Ciphertext: ")
    print(ciphertext)
    return ciphertext

ciphertext = mytest_ciphertext()

winner = find_multichar_xor(ciphertext)
print("Winning key: {}".format(winner.strxorkey))
print("Winning plaintext: {}".format(winner.plaintext))

