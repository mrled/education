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

def winnow_nulls(candidate):
    # nulls should only appear at the end I think?
    if candidate.nulls > 0:
        for i in range(len(candidate.plaintext)):
            if candidate.plaintext[i] == chr(0x00):
                try:
                    nextchar = candidate.plaintext[i+1]
                    if nextchar != chr(0x00):
                        return False
                except IndexError:
                    return True
    else:
        return True
                

def winnow_asciicontrol(candidate):
    if candidate.asciicontrol > 0:
        return False
    else:
        return True

def winnow_nonascii(candidate):
    if candidate.nonascii > 0:
        return False
    else:
        return True

def winnow_wordlength(candidate):
    try:
        avg_length = (candidate.letters + candidate.digits) / candidate.whitespace
    except ZeroDivisionError:
        avg_length = candidate.letters
    if 2 < avg_length < 8:
        return True
    else:
        return False

def winnow_punctuation(candidate):
    if candidate.punctuation < candidate.letters/7:
        return True
    else:
        return False

def winnow_vowel_ratio(candidate):
    if candidate.letters == 0:
        return True
    vr = candidate.vowels / candidate.letters
    cr = candidate.consonants / candidate.letters
    if vr > cr:
        return True
    else:
        return False

def winnow_upper_lower(candidate):
    if candidate.uppercase < candidate.lowercase:
        return True
    else:
        return False

def winnow_letter_frequency(candidate):
    pr = candidate.popchars / candidate.letters
    if .50 <= pr <= .85:
        return True
    else:
        return False


#punctuations = ""
#asciicontrols = ""
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
        self.punctuation = 0
        self.letters = 0
        self.allcharacters = len(self.plaintext)
        self.popchars = 0 # more ~60% of english letters are one of these
        self.asciicontrol = 0
        self.nulls = 0
        self.nonascii = 0
        self.punctuations = self.asciicontrols = ''
        self.uppercase = self.lowercase = 0
        for character in self.plaintext:
            ordc = ord(character)
            if ordc == 0:
                self.nulls += 1
            elif ordc <= 8:
                self.asciicontrol += 1
                self.asciicontrols += character
            elif ordc <= 10:
                self.whitespace += 1
            elif ordc <= 12:
                self.asciicontrol +=1 
                self.asciicontrols += character
            elif ordc == 13:
                # ignoring this so i dont have to deal with cr+lf vs just lf or whatever
                pass 
            elif ordc <= 31:
                self.asciicontrol += 1
                self.asciicontrols += character
            elif ordc == 127:
                self.asciicontrol += 1
                self.asciicontrols += character
            elif ordc > 127: 
                self.nonascii += 1
            elif character in string.whitespace:
                self.whitespace += 1
            elif character in 'aeiou':
                self.vowels += 1
                self.lowercase += 1
            elif character in 'AEIOU':
                self.vowels += 1
                self.uppercase += 1
            elif character in 'bcdfghjklmnpqrstvwxyz':
                self.consonants += 1
                self.lowercase += 1
            elif character in 'BCDFGHJKLMNPQRSTVWXYZ':
                self.consonants += 1
                self.uppercase += 1
            elif character in '0123456789':
                self.digits += 1
            else:
                self.punctuation += 1
                #global punctuations
                #punctuations += character

            if character in 'etaoins':
                self.popchars += 1

        self.letters = self.consonants + self.vowels

    def __repr__(self):
        return "xorchar: '{}'; hexstring: '{}'; plaintext: '{}'".format(
            self.xorchar, self.hexstring, self.plaintext)

    @classmethod
    def generate_ascii_candidates(self, hexstring):
        candidates = []
        for i in range(0, 128):
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


        self.winners = [c for c in self.candidates if winnow_asciicontrol(c)]
        #self.winners = self.candidates
        if len(self.winners) == 0:
            self.solved = False
        else:
            opt_winnowers = [winnow_nonascii,
                             winnow_asciicontrol,
                             #winnow_nulls,
                             winnow_punctuation,
                             winnow_vowel_ratio, 
                             winnow_wordlength,
                             #winnow_upper_lower,
                             winnow_letter_frequency,
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
            debugprint("Candidate winners ({} total)".format(len(self.winners)))
            for w in self.winners:
                debugprint("length: {} key char: {}".format(w.length, w.xorchar))
            # this prints the ascii control chars that were NOT present
            # it's only useful at this stage if you disable winnowing control chars, obviously
            for i in [1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 14, 15, 16, 17, 18, 19, 20, 
                      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 127]:
                present = chr(i) in w.asciicontrols
                # if not present:
                #     debugprint("    {}: {}".format(i, present))
                #debugprint("    {}: {}".format(i, present))



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

        self.plaintext = self.ascii_key = self.fullkey_ascii = self.hexxorkey = ""
        tchunk_count = len(self.tchunks)

        for i in range(0, self.tchunksize):
            for tc in self.tchunks:
                newpt = newxc = '_' # a placeholder that only gets used if there was no winner
                if tc.solved:
                    newpt = tc.winners[0].plaintext[i]
                    newxc = tc.winners[0].xorchar
                self.plaintext += newpt
                self.fullkey_ascii += newxc
                if i == self.keylen:
                    self.ascii_key += newxc
        self.hex_key = string_to_hex(self.ascii_key)
        self.hex_plaintext = string_to_hex(self.plaintext)

def find_multichar_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    # Remember that if we're assuming that our XOR key came from ASCII, it will have an even number 
    # of hex digits. 
    # Throughout this function and elsewhere, keylen is specificed in *hex* digits. 
    if len(hexstring)%2 is not 0:
        hexstring = "0"+hexstring

    keylenmin = 4
    keylenmax = 40
    #keylenmin = 18
    #keylenmax = 22
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

def repxor(plaintext=False, plainhex=False, keytext=False, keyhex=False, returnstring=False):
    """
    XOR plaintext with a repeating key and return the result in hex.

    Take a string and a key. Repeat the key as many times as is necessary. Pad 
    the plaintext with chr(0x00) so that it is equal to key length (do not truncate the key if it 
    is too long, or if it is too longer after it was repeated). XOR them together. Return
    the result.
    """
    if (plaintext and plainhex) or (not plaintext and not plainhex):
        raise Exception("Specify one of plaintext or plainhex argument, not both or neither")
    if (keytext and keyhex) or (not keytext and not keyhex):
        raise Exception("Specify one of keytext or keyhex argument, not both or neither")
    if plaintext:
        plainhex = string_to_hex(plaintext)
    if keytext:
        keyhex = string_to_hex(keytext)
    fullkeyhex = keyhex
    while len(fullkeyhex) < len(plainhex):
        fullkeyhex += keyhex
    while len(plainhex) < len(fullkeyhex):
        plainhex += ("00")
    plainbin = int(plainhex, 16)
    keybin = int(fullkeyhex, 16)
    xorbin = plainbin^keybin
    xorhex = hex(xorbin)[2:]
    if len(xorhex)%2 == 1:
        # TODO: what if there is more than one leading zero? I need to pad this to len(plainhex).
        # 
        # pad the beginning with zero so that the hexxor string has an even number of hex bits in it.
        # useful because not only does it match the provided solution this way, it also 
        # means there are two hex digits per character so the ciphertext is decodable to ASCII
        # and it's consistent with how you'd encode plaintext.
        xorhex = "0"+xorhex
    xortext = hex_to_string(xorhex)
    if returnstring:
        return(xortext)
    else:
        return(xorhex)
        
def gist_ciphertext():
    f = open("3132752.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    return base64_to_hex(gist)

def ex3_ciphertext():
    return '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'

def mytest_ciphertext():
    # the length of this string is exactly 310
    # 310/10 is 31 which is a prime. useful for testing larger keylens. 
    plaintext = 'To convert data to PEM printable encoding, the first byte is placed in the most significant eight bits of a 24-bit buffer, the next in the middle eight, and the third in the least significant eight bits. If there are fewer than three bytes left to encode (or in total), the remaining buffer bits will be zero..'
    key = 'abcdefghij'
    ciphertext = repxor(plaintext=plaintext, keytext=key, returnstring=False)
    print("Ciphertext: ")
    print(ciphertext)
    return ciphertext

def mytestshort_ciphertext():
    plaintext = 'abcdefghij'
    key = '00000000'
    ciphertext = repxor(plaintext=plaintext, keyhex=key)
    return ciphertext

if __name__ == '__main__':
    ciphertext = mytest_ciphertext()
    winner = find_multichar_xor(ciphertext)
    print("Winning key: ascii: {} hex: {} hexlen: {}".format(
        winner.ascii_key, winner.hex_key, winner.keylen))
    print("Winning plaintext:\n{}".format(winner.plaintext))
    #print("Winning hex_plaintext:\n{}".format(winner.hex_plaintext))
    #print("punctuations:")
    #print(punctuations)
    debugprint(len(winner.tchunks[0].winners))
    for w0 in winner.tchunks[0].winners:
        debugprint(w0.plaintext)
