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
