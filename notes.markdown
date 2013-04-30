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

