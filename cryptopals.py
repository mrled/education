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

def debugprint(string):
    """Print the passed string if the program is being run in debug mode."""
    if CRYPTOPALS_DEBUG:
        safeprint(string)

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
    for char in string.encode()[0:-1]: # the last character is \x00 which just terminates it, ignore that
        hexstring += '{:0>2}'.format(hex(char)[2:])
    if len(hexstring)%2 is 1:
       hextring = "0"+hexstring
    return hexstring

def hex_to_base64(hexstring):
    return base64.b64encode(hex_to_string(hexstring).encode())

def hexxor(x, y):
    """Do a XOR of two hex strings of the same length"""
    if len(x) is not len(y):
        raise Exception("Buffers diff lengths! '{}' is {} but '{}' is {}".format(
                x, len(x), y, len(y)))
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
        xorhex = string_to_hex(xortxt)
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
        if h is "":
            debugprint('what the fuck man')
        else:
            if len(h)%2 is 1:
                # pad with zero so there's an even number of hex chars
                # this way my other functions like hexxor() work properly
                h = "0" + h
            debugprint("finding 1ch xor for '{}' of len {}".format(h, len(h))) 
            strtxt = hex_to_string(h)
            
            for i in range(1, 128):
                xorhex = ""
                xorbyte = "{:0>2x}".format(i)
                for byte in range(0, int(len(h)/2)):
                    xorhex += xorbyte
    
                candidate = hexxor(h,xorhex)
                canstring = hex_to_string(candidate)

                # winnowing by wordcount only works for longer strings, not short ones
                # lik I need to use when breaking repeating-key XOR
                #if winnow_wordcount(canstring):

                debugprint("hex: {}; xor'd against: {}; plaintext candidate: {}".format(
                        h, xorbyte, canstring))
                if winnow_junk_chars(canstring):
                    p = {'hex':h, 'xorhex':xorhex, 'canstring':canstring}
                    passed += [p]

    if len(passed) is 0:
        raise Exception("NO PLAINTEXT CANDIDATE FOR {} IN ROUND ONE".format(h))


    # # Now apply other winnowing methods
    # passed2=[]
    # for p in passed:
    #     if winnow_junk_chars(p['canstring']):
    #         passed2 += [p]
    # else:
    #     debugprint("NO PLAINTEXT CANDIDATE FOR {} IN ROUND ONE".format(h))
    #     return False

    # And finally, print the winners

    # TODO: i'm returning just the first one in passed, this is wrong. 
    for p in passed:
        debugprint("Candidate: hex: {}, xorhex: {}, plaintext: {}".format(
                p['hex'], p['xorhex'], p['canstring']))
        return p['canstring']
    else:
        raise Exception("NO PLAINTEXT CANDIDATE FOR {} IN ROUND TWO".format(h))

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

def break_repkey_xor(hexstring):
    """
    Break a hexstring of repeating-key XOR ciphertext. 
    """
    # Remember that if we're assuming that our XOR key came from ASCII, it will have an even number 
    # of hex digits. 
    # Throughout this function, keylen is specificed in *hex* digits. 

    keylenmin = 2
    keylenmax = 40
    cipherlen = len(hexstring)

    # If you don't do this, and you pass it a too-short hexstring, it'll try to compare chunk1 with
    # chunk2 in the for loop, but they'll be different lengths after a while.
    if keylenmax >= int(len(hexstring)/2):
        keylenmax = int(len(hexstring)/2)
    debugprint("min key length: {} / max key length: {} / hexstring length: {}".format(
            keylenmin, keylenmax, len(hexstring)))


    #COMMENTUGH="""
    attempts = []
    for keylen in range(keylenmin, keylenmax):
        if keylen%2 is 0: # only operate on even keys because two hits is one charater
            this_attempt = {'keylen':keylen, 
                            'hd_norm':0, 
                            'orig_hexstring':hexstring,
                            'hexstring':hexstring,
                            'orig_cipherlen':cipherlen,
                            'cipherlen':cipherlen}
            if cipherlen%keylen is not 0:
                for i in range(0, cipherlen%keylen):
                    # TODO: this is ugly.
                    # only operate on every other hit because two hits is one char
                    if i%2 is 0: 
                        this_attempt['hexstring'] += "00"
                        this_attampt['cipherlen'] += 1

            debugprint("cipherlen: {},".format(this_attempt['cipherlen']))
            chunks = []
            #this_chunk = "" #I don't think I need to predefine this because keylen%i where i==0 is 0 so
            this_chunk=""
            for i in range(0, this_attempt['cipherlen']):
                try:
                    mod = i % this_attempt['keylen'] 
                except ZeroDivisionError:
                    mod = 0
                debugprint("i: {}, mod: {}, keylen: {}".format(i, mod, this_attempt['keylen']))
                if mod is 0:
                    this_chunk = this_attempt['hexstring'][i]
                else:
                    this_chunk += this_attempt['hexstring'][i]
                if len(this_chunk) is this_attempt['keylen']:
                    print(this_chunk)
                    chunks += [[this_chunk]]

            debugprint("----------------")
            debugprint(chunks)
            debugprint("----------------")
            import pdb; pdb.set_trace()
    #"""

    hamming_distances=[]
    for keylen in range(keylenmin, keylenmax):
        if keylen%2 is 0:
            chunk1 = hexstring[0:keylen]
            chunk2 = hexstring[keylen:keylen*2]
            debugprint("chunks 1/2: '{}'/'{}'".format(chunk1, chunk2))
            hd = hamming_code_distance(chunk1, chunk2)
            hd_normalized = hd/keylen
            hamming_distances += [ {'keylen':keylen, 'distance':hd_normalized} ]

    hamming_distances_sorted = sorted(hamming_distances, key=lambda hd: hd['distance'])
    if CRYPTOPALS_DEBUG:
        for hds in hamming_distances_sorted:
            print(hds)
    
    # pick the four keylens with the lowest hamming distance between chunks; one of these is probably right
    for winner in hamming_distances_sorted[0:4]:
        keylen = winner['keylen']

        # break the ciphertext hexstring chunks the size of the keylen
        winarray=[]
        for i in range(0, int(len(hexstring)/keylen)):
            j=i+1
            #chunk=winner[i:j]
            chunk=hexstring[i:j]
            winarray+=[chunk]
        if len(winarray[-1]) < keylen:
            for i in range(0, len(winarray[-1]) - keylen):
                winarray[-1] += chr(0x00)

        debugprint("---------winarray: ---------")
        debugprint(winarray)
        debugprint("----------------------------")

        # create an array containing an empty string for each transposed block,
        # and one for candidate plaintext based on it
        transposed_winarrays = []
        transposed_candidates = []
        for i in range(0, int(len(hexstring)/keylen)):
            transposed_winarrays += [ "" ]
            transposed_candidates += [ "" ]

        # populate the transposed winner array
        for i in range(0, len(hexstring)):
            tw_index = i%keylen
            transposed_winarrays[tw_index] += hexstring[i]

        debugprint("---transposed_winarrays: ---")
        debugprint(transposed_winarrays)
        debugprint("----------------------------")

        # solve each as if it's a 1 character xor to populate the cadidate plaintexts array
        for i in range(0, len(transposed_winarrays)):
            block_candidate = find_1char_xor(transposed_winarrays[i])
            if not block_candidate:
                raise Exception("No block candidate found for candidate #{}: {}".format(
                        i, transposed_winarrays[i]))
            transposed_candidates[i] = block_candidate
        debugprint("Transposed candidates: " + str(transposed_candidates))
            
        # un-transpose the candidates
        plaintext_candidate = ""
        for candidate in transposed_candidates:
            for i in range(0, keylen): # i: index of the character in each string 
                for j in range(0, len(hexstring)/keylen): # j: the index of the string in transposed_candidates
                    plaintext_candidate += transposed_candidates[j][i]

        debugprint("Plaintext candidate: " + str(plaintext_candidate))



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
    # f = open("3132752.gist.txt")
    # gist = f.read().replace("\n","")
    # f.close()
    # hexcipher = base64_to_hex(gist)
    ciphertext = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
    break_repkey_xor(ciphertext)

def chal06h():
    ex1="this is a test"
    ex2="wokka wokka!!!"
    print(hamming_code_distance(ex1, ex2))



########################################################################
## main()

CRYPTOPALS_DEBUG=False

class DebugAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        #print('%r %r %r' % (namespace, values, option_string))
        #setattr(namespace, self.dest, values)
        global CRYPTOPALS_DEBUG
        CRYPTOPALS_DEBUG = True


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
