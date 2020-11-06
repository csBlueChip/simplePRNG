# simplePRNG
A simple PRNG based on Linear Congruency. Properly documented; with bibliography.

I originally designed this at uni based on the information from the loan of a tome-of-a-maths-book ...which now appears to have its own wikipedia page! https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming

The idea was to have a PSEUDO Random Number Generator, good enough to make a game look random, efficient (for embedded platforms), consistent across all hardware and Operating Systems (or, indeed, "bare metal code"), and with the ability to rerun the game and produce identical results.

The (first) implemenation of it that I have uploaded here is "BASh script" (cos that's the project I'm currently working on) ...I hope to upload the same algorithm in other languages as-and-when I get around to it - but it's essentially ONE line of code to perform the L.C. operation "X <- (aX + c) mod m", and a second line of code to sort out the issue with bit entropy [explained in the code].

With certain considerations [see code] it can be implemnented in Assembler in as few as THREE OR FOUR instructions, and a single 32bit variable ...so it is **blindingly** fast AND **incredibly** memory efficient.

## HOWEVER... Caveat pre-emptor:
All those fantastic things come, inevitably, with a price...

It is *ideal* for my use-case (game logic), and (as it stands) produces just shy of a million numbers before the pattern repeats [see code].

**BUT** DO NOT ...I'm gonna repeat that ...DO **NOT** under ANY (sane) circumstances use this for cryptography, gambling scenarios, or *anywhere* that brute-forcing a million numbers might end in disaster!
