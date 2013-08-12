#!/usr/bin/env python3

import argparse
import base64
import string
import sys
import math
import binascii

########################################################################
## Backend libraryish functions

def safeprint(text, unprintable=False, newlines=False, maxwidth=None):
    """
    Attempt to print the passed text, but if a UnicodeEncodeError is 
    encountered, print a warning and move on. 

    This is useful when printing candidate plaintext strings, because Windows
    will throw a UnicodeEncodeError if you try to print a character it can't 
    print or something, and your program will stop.

    If the appropriate options are passed, it will also filter the text through 
    safefilter().

    """

    filtered = safefilter(text, 
                          unprintable=unprintable, 
                          newlines=newlines,
                          maxwidth=maxwidth)

    try:
        print(filtered)
    except UnicodeEncodeError:
        # this (usually?) only happens on Windows
        wt = "WARNING: Tried to print characters that could not be displayed on "
        wt+= "this terminal. Skipping..."
        print(wt)

def safefilter(text, unprintable=False, newlines=False, maxwidth=None):
    """
    Filter out undesirable characters from input text. (Intended for debugging.)

    If `unprintable` is set to True, any character not printable
    be rendered as an underscore. Note that of course you may have actual 
    underscores in your `text` as well! 

    If `newlines` is set to True, ASCII characters 10 and 13 (CR and LF) will 
    be rendered as an underscore.

    If `maxwidth` is set to an integer, text will be truncated and an elipsis
    inserted.
    """
    text = str(text)

    if maxwidth and len(text) > maxwidth:
        output1 = text[0:maxwidth-3] + "..."
    else:
        output1 = text

    if unprintable or newlines:
        output2 = ""
        for character in output1:
            #if unprintable and (chr(character) not in string.printable):
            if unprintable and (character not in string.printable):
                output2 += "_"
            elif newlines and (ord(character) == 10 or ord(character) == 13):
                output2 += "_"
            else:
                output2 += character
    else:
        output2 = output1

    return output2

        
# idk if these are like cheating or something because they're using the base64 
# module? 
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
    for i in range(0, len(hexstring), 2):
        decoded += chr(int(hexstring[i:i+2], 16))
    return decoded

def hex_to_bin(hexstring):
    bs = int(hexstring, 16)
    return bs

def bin_to_hex(integer):
    return hex(integer)

# this isn't used anywhere
# ... plus I think it actually doesn't work
# TODO: replace with hexlify or equialient
# TODO: look at other helper functions like this and replace them similarly
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

def xor_hexstrings(plaintext, key):
    """
    Take two hex strings and xor them together. 
    Return the result as a hex string. 

    The first is treated as the "plaintext" hex string. 
    The second is treated as the "key" hex string. If the key is shorter than
    the plaintext, it is repeated as many times as is necessary until they
    are of equal length. 
    """

    # repeat the key as many times as necessary to be >= length of the plaintext
    repcount = math.ceil(len(plaintext)/len(key))
    fullkey = key * repcount

    # make sure the key didnt end up longer than the plaintext by the repetition
    fullkey = fullkey[0:len(plaintext)]
    
    xorbin = int(plaintext, 16) ^ int(fullkey, 16)
    xorhex = '{:0>2x}'.format(xorbin) # chomp leading '0x'

    # if the xor results in a number with leading zeroes, make sure they're 
    # added back so that the ciphertext is the same length as the plaintext
    diff = len(plaintext) - len(xorhex)
    for i in range(0, diff):
        xorhex = "0" + xorhex

    return xorhex

def xor_strings(plaintext, key):
    """
    Xor the given plaintext against the given key. 
    Return the result in a hexstring.

    If the plaintext is longer than the key, repeat the key as many times as is
    necessary.
    """

    # repeat the key as many times as necessary to be >= length of the plaintext
    repcount = math.ceil(len(plaintext)/len(key))
    fullkey = key * repcount

    # make sure the key didnt end up longer than the plaintext by the repetition
    fullkey = fullkey[0:len(plaintext)]

    phex = binascii.hexlify(plaintext.encode())
    khex = binascii.hexlify(key.encode())
    x = xor_hexstrings(phex, khex)

    return(x)

def char_counts(text):
    """
    Count different types of characters in a text. Useful for statistical 
    analysis of candidate plaintext.
    """
    vowels = 'aeiouAEIOU'
    consonants = 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    count={'w':0, 'v':0, 'c':0, 'o':0,
           'printable':0, 'unprintable':0,
           'bad_lineendings':0}
    index = 0
    for character in text:
        if character in string.whitespace:
            count['w'] += 1
        elif character in vowels:
            count['v'] += 1
        elif character in consonants:
            count['c'] += 1
        else:
            count['o'] += 1

        if character in string.printable:
            count['printable'] += 1
        else:
            count['unprintable'] += 1

        # check for linefeeds. if there's \r\n, assume OK (windows standard),
        # but if \r by itself, assume bad (nothing uses \r by itself)
        if ord(character) is 13: 
            if index+1 >= len(text) or ord(text[index+1]) is not 10:
                pass
            else:
                count['bad_lineendings'] += 1
            text[index-1]

        index += 1

    count['l'] = count['c'] + count['v']
    return count

def winnow_wordlength(text):
    """
    Return True if some text contains 1-9 letters per space, False otherwise.
    English has an average word length of about five letters.
    """
    count = char_counts(text)
    try:
        avg_length = count['l'] / count['w']
    except ZeroDivisionError:
        avg_length = count['l']
    if 2 < avg_length < 12:
        return True
    else:
        return False

def winnow_unprintable_ascii(text):
    """
    Return False if a text contains any non-ascii (or non-printable ascii) characters; 
    True otherwise.
    """
    cc = char_counts(text)

    # spt = "UA: {} BLE: {} WUA: {}".format(
    #     cc['unprintable'], cc['bad_lineendings'], text)
    # safeprint(spt, unprintable=True)
        
    if cc['unprintable'] > 0 or cc['bad_lineendings'] > 0:
        return False
    else:
        return True

def winnow_punctuation(text):
    """
    Return False if a text contains too many non-letter non-space characters,
    True otherwise.
    """
    count = char_counts(text)
    if count['o'] < len(text)/8:
        return True
    else:
        return False

def winnow_vowel_ratio(text):
    count = char_counts(text)
    # in English text, v/c ratio is about 38/62 i.e. 0.612
    # https://en.wikipedia.org/wiki/Letter_frequency
    try:
        vc_ratio = count['v']/count['c']
    except ZeroDivisionError:
        vc_ratio = 1
    if 0.20 < vc_ratio < 0.99:
        return True
    else:
        return False

def winnow_plaintexts(candidates):

    can2 = []

    if CRYPTOPALS_DEBUG:
        csup = sorted(candidates, key=lambda c: c.charcounts['unprintable'])
        # for c in candidates:
        #     safeprint(c.plaintext, underscores=True, maxwidth=80)

    for c in candidates:
        if winnow_unprintable_ascii(c.plaintext):
            can2 += [c]
    if len(can2) == 0:
        et = "Unprintable ASCII winnowing failed. "
        et+= "Found no candidates which didn't result in unprintableascii characters "
        et+= "for this hexstring: \n    '{}'".format(
            candidates[0].hexstring[0:72] + "...")
        raise MCPWinnowingError(et)
    candidates = can2

    opt_winnowers = [winnow_punctuation,
                     winnow_vowel_ratio, 
                     winnow_wordlength,
                     lambda x: True] # the final one must be a noop lol TODO

    for w in opt_winnowers:
        # dp = "WINNOWING USING METHOD {}, BEGINNING WITH {} CANDIDATES".format(
        #         w.__name__, len(candidates))
        # debugprint(dp)
        can2 = []
        for c in candidates:
            if w(c.plaintext):
                can2 += [c]
        if len(can2) is 1:
            candidates = can2
            break
        elif len(can2) is 0:
            # dp = "WINNOWING METHOD {} RESULTED IN ZERO CANDIDATES, ".format(
            #     w.__name__)
            # dp+= "ROLLING BACK..."
            # debugprint(dp)
            # ... and you don't actually have to roll back, you just have to ignore can2
            pass
        else:
            candidates = can2

    #ideally there will be only one candidate butttt
    # TODO: winnow better so there's guaranteed to be just one candidate dummy

    if len(candidates) == 0:
        return False
    elif len(candidates) > 1:
        debugprint("WINNOWING COMPLETE BUT {} CANDIDATES REMAIN".format(len(candidates)))

    return candidates

# TODO: test before next commit
def detect_1char_xor(hexes):
    candidates = []
    for h in hexes:
        candidates += SingleCharCandidate.generate_set(h)

    can2 = winnow_plaintexts(candidates)
    winner = can2[0]

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
        # this way my other functions like work properly
        h = "0" + h
    for i in range(0, 128):
        candidates += [SingleCharCandidate(hexstring, chr(i))]

    can2 = winnow_plaintexts(candidates)
    candidates = can2

    #ideally there will be only one candidate butttt
    # TODO: winnow better so there's guaranteed to be just one candidate dummy
    if len(candidates) == 0:
        return False
    elif len(candidates) > 1:
        debugprint("WINNOWING COMPLETE BUT {} CANDIDATES REMAIN".format(
            len(candidates)))
    return candidates[0]

class MCPWinnowingError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class SingleCharCandidate(object):
    """
    Bundle for the following data:
    -   a hex cipherstring
    -   a single character to xor it against
    -   the result of that xor
    """
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
        hex_plaintext = xor_hexstrings(self.hexstring, self.hex_xorchar)
        self.plaintext = hex_to_string(hex_plaintext)
        self.charcounts = char_counts(self.plaintext)

    def __repr__(self):
        #return "xorchar: '{}'; hexstring: '{}'; plaintext: '{}'".format(
        #    self.xorchar, self.hexstring, self.plaintext)
        if len(self.plaintext) > 50:
            pt = safefilter(self.plaintext[0:47] + "...", 
                            unprintable=True, newlines=True)
        else:
            pt = safefilter(self.plaintext, 
                            unprintable=True, newlines=True)
        r = "xorchar: {} plaintext: {}".format(self.xorchar, pt)
        return(r)

    @classmethod
    def generate_set(self, hexstring):
        candidates = []
        for i in range(0, 128):
            candidates += [SingleCharCandidate(hexstring, chr(i))]
        return candidates

class TchunkCandidateSet(object):
    """
    A set of candidates for a tchunk.

    Contains the text of the tchunk itself, all 128 SingleCharCandidate objects
    generated by SingleCharCandidate.generate_set(), and an array called 
    `winners` that contains the best of those SCC objects as judged by whether 
    they pass a series of winnowing tests.     
    """
    def __init__(self, text):
        """
        -   Take in text from a tchunk (a transposed chunk from a 
            MultiCharCandidate)
        -   Brute force a plaintext from that ciphertext by calling
            SingleCharCandidate.generate_set()
        -   Winnow those 128 candidates down to (ideally) just one
            winner.
        """
        self.text = text

        # calculate the possibilities for this chunk
        self.candidates = SingleCharCandidate.generate_set(self.text)

        self.solved = True
        self.winners = []
        # now winnow the plaintexts down for each tchunk
        # TODO: note that right now this may have several winners! make sure to
        # handle that elsewhere
        tcwinners = winnow_plaintexts(self.candidates)

        if tcwinners:
            self.winners = tcwinners
        else:
            self.winners = False
            self.solved = False

    def __repr__(self):
        if self.solved:
            solvstring = "solved ({} winners)".format(len(self.winners))
        else:
            solvstring = "unsolved"
        repr = "<TchunkCandidateSet: {}, ".format(solvstring)
        return repr


class MultiCharCandidate(object):
    """
    A bundle for the following related pieces of data:
    -   a single piece of ciphertext (represented in *hex*)
    -   a single key which is assumed to be multiple ascii characters long 
        (represented in *hex*)
    -   chunks: the ciphertext, divided into chunks len(key) long
    -   tchunks: those chunks, transposed
    -   the hamming code distance between chunks[0] and chunks[1]
    -   for each tchunk, a TchunkCandidateSet object 
    -   a plain text that is reassembled from the TchunkCandidateSet objects
    """
    def __init__(self, hexstring, keylen):
        self.keylen = keylen

        if int(len(hexstring)%2) != 0:
            self.hexstring = "0" + hexstring
        else:
            self.hexstring = hexstring

        self.cipherlen = len(self.hexstring)
        self.tchunksize = math.ceil(self.cipherlen/self.keylen) 

        # only operate on even-length keys because two hits is one charater
        if self.keylen%2 != 0:
            es = "Cannot create a MultiCharCandidate object with an odd keylen"
            raise Exception(es)

        # divide the ciphertext into chunks
        self.chunks = []
        this_chunk = ""
        # I have to use cipherlen+1 or this will stop on the second to last char
        # ... This is ugly and should be fixed probably, but I'm too tired
        for i in range(0, self.cipherlen+1, 2):
            this_chunk += self.hexstring[i:i+2]
            if len(this_chunk) == self.keylen or i >= self.cipherlen:
                self.chunks += [this_chunk]
                this_chunk = ""

        hd = hamming_code_distance(self.chunks[0], self.chunks[1])
        self.hdnorm = hd/self.keylen

        # build the transposed chunks
        # you have len(chunks)/2 many chunks, that are all keylen/2 long
        # you'll end up with keylen/2 many transposed chunks that are all 
        # len(chunks)/2 long. 
        # (you divide all of those by two because two hits make up one char)
        self.tchunks = []
        self.solved_all = True
        for i in range(0, self.keylen, 2):
            new_tchunk_text = ""
            for c in self.chunks:
                new_tchunk_text += c[i:i+2]
            new_tchunk = TchunkCandidateSet(new_tchunk_text)
            self.tchunks.append(new_tchunk)
            if not new_tchunk.solved:
                self.solved_all = False

        self.plaintext = self.key = self.fullkey = ""
        tchunk_count = len(self.tchunks)

        for i in range(0, self.tchunksize):
            for tc in self.tchunks:
                # use an underscore as a temp value that gets printed if there
                # was no winner
                newpt = newxc = '_' 
                if tc.solved:
                    try: 
                        tcw = tc.winners[0]
                        newpt = tcw.plaintext[i]
                        newxc = tcw.xorchar
                    except IndexError:
                        # this only ever happens for the last tchunks of the 
                        # bunch, when the keylen doesn't divide evenly into
                        # the cipherlen
                        pass
                    #newpt = tc.winners[0].plaintext[i]
                    #newxc = tc.winners[0].xorchar
                self.plaintext += newpt
                self.fullkey += newxc

                if i == 0:
                    self.key = self.fullkey

    def __repr__(self):
        repr = "<MultiCharCandidate: key(hex): {} hdnorm: ~{} tchunks: {}>"
        repr = repr.format(
            binascii.hexlify(self.key.encode()), 
            round(self.hdnorm, 4),
            len(self.tchunks))
        return repr

    def diag(self):
        repr = self.__repr__()
        for tc in self.tchunks:
            repr += "\n  {}".format(tc.__repr__())
            for w in tc.winners:
                wrepr = w.__repr__()
                wrepr = wrepr.replace("\n","_").replace("\r","_")
                wrepr = "\n    " + wrepr
                repr += wrepr
        safeprint(repr)

class AesEcbCandidate(object):
    def __init__(self, ciphertext, keylen):
        self.keylen = keylen
        self.ciphertext = ciphertext

        # self.tchunks = []
        # this_tchunk = ""
        # for i in range(0, len(ciphertext)):
        #     this_tchunk += ciphertext[i]
        #     if (i+1)%keylen:
        #         self.tchunks += this_tchunk
        #         this_tchunk = ""

        # for i in range(0, len(ciphertext)):
        #     if i%keylen:
        #         this_tchunk = ""
        #     this_tchunk += ciphertext[i]

        # for i in range(0, math.ceil(len(ciphertext)/keylen)):
        #     for j in range(0, keylen):
        #         self.tchunks[j] += 


        # for tcindex in range(0, keylen):
        #     self.tchunks[tcindex] = ""
        #     for charindex in range(tcindex, len(ciphertext), keylen):
        #         self.tchunks[tcindex] += ciphertext[charindex]

        tchunks = []
        for tcindex in range(0, keylen):
            tchunks[tcindex] = ""
            for charindex in range(tcindex, len(ciphertext), keylen):
                tchunks[tcindex] += ciphertext[charindex]

def hamming_code_distance(string1, string2):
    """
    Compute the Hamming Code distance between two strings
    """
    if len(string1) is not len(string2):
        # If strings are different lengths, truncate the longer one so that you 
        # can do the compare
        string1 = string1[0:len(string2)]
        string2 = string2[0:len(string1)]
        #raise Exception("Buffers are different lengths!")
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
        i +=1
    return hamming_distance

def find_multichar_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    # Remember that if we're assuming that our XOR key came from ASCII, it will
    # have an even number of hex digits. 
    # Throughout this function and elsewhere, keylen is specificed in *hex* 
    # digits. 
    if len(hexstring)%2 is not 0:
        hexstring = "0"+hexstring

    keylenmin = 2
    keylenmax = 80
    cipherlen = len(hexstring)

    dp = "min key length: {} / ".format(keylenmin)
    dp+= "max key length: {} / ".format(keylenmax)
    dp+= "hexstring length: {}".format(len(hexstring))
    debugprint(dp)

    attempts = []
    # only operate on even-length keys because two hits is one charater:
    for keylen in range(keylenmin, keylenmax, 2):
        # if the MCC results in a winnowing error, ignore that keylen:
        try:
            na = [MultiCharCandidate(hexstring, keylen)]
            attempts += na
        except MCPWinnowingError:
            debugprint("Winnowing exception for keylen {}".format(keylen))

    attempts_sorted  = sorted(attempts, key=lambda a: a.hdnorm, reverse=True)
    winner = attempts_sorted[0]

    if CRYPTOPALS_DEBUG: 
        print("########   winning MCC diagnostic:   ########")
        winner.diag()
        print("######## sorted attempts diagnostic: ########")
        for a in attempts_sorted[0:10]:
            print(a)
        print("########     ###################     ########")
        print()

    return winner


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
    calculated = xor_hexstrings(ex1, ex2)
    print("ex1: " + ex1)
    print("ex2: " + ex2)
    print("res: " + res)
    print("calculated result:\n     " + calculated)

def chal03():
    ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
    print(find_1char_xor(ciphertext))

def chal04():
    gist = open("data/challenge04.3132713.gist.txt")
    hexes = [line.strip() for line in gist.readlines()]
    gist.close()
    winner = detect_1char_xor(hexes)
    if winner:
        print("Detected plaintext '{}'".format(winner.plaintext))
        print("From hex string '{}'".format(winner.hexstring))
        print("XOR'd against character '{}'".format(winner.xorchar))
    else:
        print("Could not find a winner.")

def chal05():
    plaintext = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
    repkey = "ICE"
    solution = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
    print("The calculated result:")
    print(xor_strings(plaintext, repkey))
    print("The official solution:")
    print(solution)

def chal06():
    f = open("data/challenge06.3132752.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    hexcipher = base64_to_hex(gist)
    winner = find_multichar_xor(hexcipher)
    print("Winning plaintext:")
    print(winner.plaintext)
    print()
    print("Key: '{}' of len {}".format(winner.key, winner.keylen))

def chal06a():
    ex1="this is a test"
    ex2="wokka wokka!!!"
    print("Hamming code distance between: \n\t{}\n\t{}".format(ex1, ex2))
    print("... is: {}".format(hamming_code_distance(ex1, ex2)))

def chal06b():
    ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
    winner = find_multichar_xor(ciphertext)
    print(winner.plaintext)

def chal07():
    # note: requires pycrypto
    from Crypto.Cipher import AES
    key = b'YELLOW SUBMARINE'
    cipher = AES.new(key, AES.MODE_ECB)

    f = open("data/challenge07.3132853.gist.txt")
    gist = f.read().replace("\n","")
    f.close()
    ciphertext = base64.b64decode(gist.encode())
    
    plaintext = cipher.decrypt(ciphertext).decode()
    print(plaintext)

def chal08():
    f = open("data/challenge08.3132928.gist.txt")
    hexes = [line.strip() for line in f.readlines()]
    f.close()

    for h in hexes:
        asc = binascii.unhexlify(h)
        #safeprint(h, unprintable=True, maxwidth=80)

    ciphertext = binascii.unhexlify(hexes[0])
    strace()
    


########################################################################
## main()

CRYPTOPALS_DEBUG=False

def strace():
    pass
def debugprint():
    pass

class DebugAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):

        global CRYPTOPALS_DEBUG
        CRYPTOPALS_DEBUG = True

        global debugprint
        def debugprint(text):
            """
            Print the passed text if the program is being run in debug mode.
            """
            safeprint("DEBUG: " + str(text))

        try:
            from IPython.core.debugger import Pdb

            global strace 
            strace = Pdb(color_scheme='Linux').set_trace

            from IPython.core import ultratb
            ftb = ultratb.FormattedTB(mode='Verbose', 
                                      color_scheme='Linux', call_pdb=1)
            sys.excepthook = ftb

        except ImportError:
            global strace
            from pdb import set_trace as strace

            global fallback_debug_trap
            def fallback_debug_trap(type, value, tb):
                """
                Print some diagnostics, colorize the important bits, and then 
                automatically drop into the debugger when there is an unhandled 
                exception.

                NOTE: If IPython is installed, this is never used! 
                IPython.core.ultratb.FormattedTB() is used in that case. 
                """
                import traceback
                import pdb
                from pygments import highlight
                from pygments.lexers import get_lexer_by_name
                from pygments.formatters import TerminalFormatter
                tbtext = ''.join(traceback.format_exception(type, value, tb))
                lexer = get_lexer_by_name("pytb", stripall=True)
                formatter = TerminalFormatter()
                sys.stderr.write(highlight(tbtext, lexer, formatter))
                pdb.pm()

            sys.excepthook = fallback_debug_trap

            

if __name__=='__main__':
    argparser = argparse.ArgumentParser(description='Matasano Cryptopals Yay')
    argparser.add_argument('--debug', '-d', nargs=0, action=DebugAction,
                           help='Show debugging information')
    subparsers = argparser.add_subparsers()
    h="Run one of the challenge assignments directly"
    subparser_challenges = subparsers.add_parser('challenge', 
                                                 aliases=['c','ch','chal'], 
                                                 help=h)
    h='Choose the challenge number you want to run'
    subparser_challenges.add_argument('chalnum', type=str, action='store', 
                                      help=h)

    subparser_challenges.set_defaults(func=challenger)

    parsed = argparser.parse_args()
    parsed.func(parsed)
