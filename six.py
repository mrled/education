#!/usr/bin/env python3

import base64
import string
import sys

from pdb import set_trace as strace

CRYPTOPALS_DEBUG = True

def safeprint(text):
    safetext = ""
    for character in text:
        ordc = ord(character)
        if character in string.whitespace:
            safetext += ' '
        elif 31 <= ordc <= 127:
            safetext += character
        else:
            safetext += '£' # might need to tweak this on Windows...
    try:
        print(safetext)
    except UnicodeEncodeError:
         print("WARNING: Tried to print chars that couldn't be shown on this terminal. Skipping...")

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
    for i in range(len(bytes1)):
        char1 = bytes1[i]
        char2 = bytes2[i]
        bin1 = "{:0>8}".format(bin(char1)[2:])
        bin2 = "{:0>8}".format(bin(char2)[2:])
        for j in range(8):
            if bin1[j] is not bin2[j]:
                hamming_distance += 1
    return hamming_distance

def hex_to_string(hexstring):
    # each PAIR of hex digits represents ONE character, so grab them by twos
    character=""
    decoded=""
    for i in range(0, len(hexstring), 2):
        decoded += chr(int(hexstring[i:i+2], 16))
    return decoded

def winnow_nulls(candidate):
    # nulls should only appear at the end as padding
    # note that a candidate will falsely pass winnowing if it has nulls at the end, 
    # but other tchunks have non-nulls that come later. I don't think that's a huge 
    # problem but it's worth noting that this isn't perfect without tchunk lookahead. 
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

        self.whitespace = self.digits = self.punctuation = self.letters = 0
        self.asciicontrol = self.nulls = self.nonascii = 0
        self.allletters={'a':0,'b':0,'c':0,'d':0,'e':0,'f':0,'g':0,'h':0,'i':0,
                         'j':0,'k':0,'l':0,'m':0,'n':0,'o':0,'p':0,'q':0,'r':0,
                         's':0,'t':0,'u':0,'v':0,'w':0,'x':0,'y':0,'z':0, 
                         'whitespace':0, 'other':0}
                           
        #for character in self.plaintext:
        for i in range(len(self.plaintext)):
            character = self.plaintext[i]
            ordc = ord(character)

            if character in string.ascii_letters:
                self.letters += 1
                self.allletters[character.lower()] += 1
            elif character in string.punctuation:
                self.punctuation += 1
            elif character in string.digits:
                self.digits += 1
            elif character in string.whitespace:
                self.whitespace += 1
            elif ordc > 127:
                self.nonascii += 1
            elif ordc == 13: 
                # ideally i'd check if the CR char was followed by LF, but that LF would be
                # in another tchunk, so that's kinda hard... 
                # ... so we need tchunk lookahead to do this too 
                #self.asciicontrol +=1 
                pass
            elif ordc == 0:
                self.nulls += 1
            else:
                self.asciicontrol += 1

        # from: http://www.cl.cam.ac.uk/~mgk25/lee-essays.pdf p181. via: wikipedia.
        self.avghistogram = {
            'a':.0609, 'b':.0105, 'c':.0284, 'd':.0292, 'e':.1136,
            'f':.0179, 'g':.0138, 'h':.0341, 'i':.0544, 'j':.0024,
            'k':.0041, 'l':.0292, 'm':.0276, 'n':.0544, 'o':.0600,
            'p':.0195, 'q':.0024, 'r':.0495, 's':.0568, 't':.0803,
            'u':.0243, 'v':.0097, 'w':.0138, 'x':.0024, 'y':.0130,
            'z':.0003, 'whitespace':.1217, 'other':.0657 }

        self.allletters['whitespace'] = self.whitespace
        self.allletters['other'] = self.punctuation + self.digits

        self.histdifference = 0
        self.histogram={}
        for letter in self.allletters:
            try:
                self.histogram[letter] = self.allletters[letter]/self.letters
            except ZeroDivisionError:
                self.histogram[letter] = 0
            self.histdifference += abs(self.avghistogram[letter] - self.allletters[letter])

    def __repr__(self):
        histd = '{:0>8}'.format(round(self.histdifference, 6))
        ptmaxlen = 30
        if len(self.plaintext) <= ptmaxlen:
            pt = self.plaintext
        else:
            ptmaxlen = ptmaxlen - 3
            pt = self.plaintext[0:ptmaxlen] + "..."
        retval = "1cc: xor: {}, histd: {}, plain: {}".format(self.xorchar, histd, pt)
        return retval

    @classmethod
    def generate_ascii_candidates(self, hexstring):
        candidates = []
        #for i in range(0, 128):
        for i in range(32, 127):
            candidates += [SingleCharCandidate(hexstring, chr(i))]
        return candidates


class TchunkCandidateSet(object):
    def __init__(self, text):
        self.text = text
        self.solved = True

        # calculate the possibilities for this chunk
        self.candidates = SingleCharCandidate.generate_ascii_candidates(self.text)
        self.winners = self.candidates
        self.winners = [c for c in self.winners if winnow_asciicontrol(c)]
        self.winners = [c for c in self.winners if winnow_nulls(c)]
        if len(self.winners) == 0:
            self.solved = False
        else:
            sorted_winners = sorted(self.winners, key=lambda w: w.histdifference)
            self.winners = sorted_winners

class MultiCharCandidate(object):
    def __init__(self, hexstring, keylen):
        self.keylen = keylen

        if int(len(hexstring)%2) != 0:
            self.hexstring = "0" + hexstring
        else:
            self.hexstring = hexstring

        self.cipherlen = len(self.hexstring)

        # -   only operate on even-length keys because two hits is one character
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

        # TODO: this is probably overly complicated
        hds = []
        self.hdnorm = 0
        for i in range(0, len(self.chunks), 2):
            try:
                tmphdn = hamming_code_distance(self.chunks[i], self.chunks[i+1])/self.keylen
                hds.append(tmphdn)
            except IndexError:
                pass
        for h in hds:
            self.hdnorm += h
        self.hdnorm = self.hdnorm / len(hds)

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

    def __repr__(self):
        retval =  "MultiCharCandidate: {}, of hex len: {}, hdnorm: {}\n".format(
            "solved" if self.solved_all else "unsolved", self.keylen, self.hdnorm)
        for i in range(len(self.tchunks)):
            tc = self.tchunks[i]
            retval += "    tchunks[{}]: {} with {} winners\n".format(
                i, "solved" if tc.solved else "unsolved", len(tc.winners))
        return retval

    def print_winners(self, tchunk="all"):
        if tchunk == "all":
            for i in range(len(self.tchunks)):
                tc = self.tchunks[i]
                safeprint("tchunks[{}]: {} with {} winners".format(
                    i, "solved" if tc.solved else "unsolved", len(tc.winners)))
                for winner in tc.winners:
                    safeprint("  {}".format(winner))
        else:
            tc = self.tchunks[tchunk]
            safeprint("tchunks[{}]: {} with {} winners".format(
                tchunk, "solved" if tc.solved else "unsolved", len(tc.winners)))
            for winner in tc.winners:
                safeprint("  {}".format(winner))
        

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

    attempts_sorted = sorted(attempts, key=lambda a: a.hdnorm)
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
    while len(xorhex) < len(plainhex):
        xorhex = "0" + xorhex
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
    key = 'abcdefghi'
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

    winner.print_winners()

    safeprint("Winning key: ascii: {} hex: {} hexlen: {}".format(
        winner.ascii_key, winner.hex_key, winner.keylen))
    safeprint("Winning plaintext:\n{}".format(winner.plaintext))
    #print("Winning hex_plaintext:\n{}".format(winner.hex_plaintext))

    strace()
