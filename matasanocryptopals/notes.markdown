# Matasano Cryptopals Notes

General notes on my code go up here at the top in whatever order I leave them in.

## Padding hex strings with zero

I have several parts in the code that look like this: 

    if len(hex_string)%2 is 1:
        hex_string = "0"+hex_string

Why? 

-   I'm dealing with hex strings that I am assuming represent ASCII. 
-   Each hex digit ("hit", after "binary digit" -> "bit") can represent 0x0-0xF i.e. in decimal 0-15.
-   Two hex digits are required to represent numbersa from 0-255 i.e. 0x00-0xFF, so I'm pretty much
    always dealing with hex two digits at a time.
    -   (Note: I'm ignoring signed vs unsigned here, but so far I've only had to deal with ASCII 
        chars which means through 128, so it doesn't matter.)
-   However, sometimes, particularly dealing with the results of a XOR, I'll get hex strings with an
    odd number of hits. To XOR that with hex that comes from ASCII, I need to add a leading zero so
    the hex strings are the same length. 

# Complog

Specific notes about what I was doing at the time go down here at the bottom in chronological order. 

## Stuck 2013-04-26

I think I must be transposing the strings wrong or something inside `break_repkey_xor()` around ln 331. It gets through the first block with a candidate (actually more than one - need to fix that too), but cannot find a single candidate for the second block, based on `winnow_junk_chars()` alone. If you try to print the result of a XOR against every character from 1-128 on Windows, it can't do it - it fails with the `UnicodeEncodeError`. 

## It is not safe to modify a list while iterating over it 2013-04-29

Fuckin lol

Don't do this

    for c in candidates:
        i += 1
        s = c['canstring']
        if not winnow_non_ascii(s):
            debugprint("Removing canstring {}".format(s))
            candidates.remove([c])
        else:
            debugprint("Keeping canstring {}".format(s))

## 20130430 cipherlen % keylen

I had code inside `break_repkey_xor()` that looked like this: 

    modlen = cipherlen%keylen
    if modlen is not 0:
        for i in range(0, keylen-modlen):
            this_attempt['hexstring'] += "0"
            this_attempt['cipherlen'] += 1

This is code that caused me a bunch of problems, but I'm confident it's pretty well debugged now. 

This code exists to deal with situations where a key doesn't divide some ciphertext evenly. In that situation, the plaintext would have been padded at the end with null (0x00) bytes, so if I want to break it I'l have to add them back. 

Except that doesn't make any fucking sense. I already have the ciphertext so, if the key didn't divide evenly into the plaintext, the nulls would already be there. This means I can ignore any keylen that doesn't divide evenly in to the ciphertext!? I think. Wow. That makes this a lot easier. FUCK I AM DUMB. 


Here's more dumb code from big dumb me:

            # if cipherlen%keylen is not 0:
            #     strace()
            #     break
            # modlen = cipherlen%keylen
            # if modlen is not 0:
            #     for i in range(0, keylen-modlen):
            #         # TODO: this is ugly.
            #         # only operate on every other hit because two hits is one char
            #         # if i%2 is 0: 
            #         #     this_attempt['hexstring'] += "00"
            #         #     this_attempt['cipherlen'] += 1
            #         this_attempt['hexstring'] += "0"
            #         this_attempt['cipherlen'] += 1

## 20130430 big milestone

This commit lets me get the correct answer from chal03 using the code for chal06! 

However, it still breaks on the hex from the big base64 gist. 

Other big TODO items: 

-   make sure it gets winnowed to exactly one candidate within `find_1char_xor()`
    and then return that candidate only. Now I'm just winnowing it to >0 and 
    then returning the first one (which will happen to be the lowest ASCII 
    character).
-   in `break_repkey_xor()` I need to deal with situations where there aren't 
    any winners that made it through the winnowing process. I also want to
    be able to return 2-4 instead of just one, but I'm just grabbing the 
    first in the array right now. 
-   There is some problem that manifests when you have `max_winners` set to 4 and you 
    are trying to complete chal03 with this code. It breaks, not sure why, but
    I've just set `max_winners` to 1 for now. 

## breaking single-char xor with my multi-char function

I've been using the single-char xored text from challenge three as a test of my multi-char xor function. The text is xored against a string of repeating 'X' characters (0x58). 

Interestingly, when I come up with possibilities and sort them by normalized Hamming distance, breaking the ciphertext into two char (aka four hit) chunks has a lower hamming edit distance (1.5) than one char (aka two hit) does (2.5). This means it ends up chopping it in half and solving each half separately. 

## bugs in hexxor()

-   I was using `len(x) is not len(y)` instead of `len(x) != len(y)`. Oops. 
-   I wasn't accounting for a XOR operation that would return a number with fewer digits because the
    most significant digits were zeroes. 

Now I'm producing shitty plaintext for challenge 06, but I am hoping I can just fix that by tweaking the winnowing algorithm. 


# stack

⁃   do challenge 08
⁃   create the same system as for 06: MCC, Tchunk, SCC.
⁃   run into a problem. In chal 08 we know the keylen is 16 bytes (aka 16 ascii chars). The possible ciphertexts are 160 characters long; this means there will be 16 tchunks of 10 characters each. for Xor, this means you'd have a fullkey of xorchar*10, but AES apparently requires keys of 16, 24, or 32 bytes, meaning we have a 16 char minimum for len(fullkey).
⁃   not sure what to do now? 
⁃   Maybe I can do something similar but kinda hacky. Don't break it into tchunks. Just iterate one of the characters at a time. 


HEAP
clean up old code, check make sure all functions are used
PEP8 compliant


IDEAS on how to proceed: 

⁃   divide each hex into 16 byte chunks and see if any are repeated within a given hex
⁃   brute force generate all possible 16 byte keys and then decrypt all the ciphertexts using them.
⁃   is this 128**16 (128 ascii values times 16 places)? 5.19229685853483E33
⁃   is it 2**128 (16 byte keys are 128 bit keys)?            3.40282366920938E38
⁃   the fact that I know it's a 128 bit / 16 byte AES key means I can break it into tchunks
⁃   and the fact that it's ECB mode means that if I have a ciphertext with one character, and the same character elsewhere in the ciphertext, the same character from the key must have encrypted that ciphertext character. 
⁃   Combining that, though, it means that characters 16 bytes apart must have been encrypted with the same key. 
⁃   All of the hexes are encoded from 160 ascii characters, meaning 16 tchunks of 10 characters each

How can I prove that a given hex ISN'T encrypted with 128 bit aes ecb? 
