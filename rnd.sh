#!/bin/bash

#****************************************************************************** ****************************************
# BASh "Linear Congruency" Pseudo Random Number Generator [PRNG]
# I designed this for a game where I wanted repeatable consistency over events
# Do NOT, I repeat, *DO NOT* use something this basic for crypto!
#
#****************************************************************************** ****************************************
# My original notes:
#
# Random number generator
# ~~~~~~~~~~~~~~~~~~~~~~~
# 
# X <- (aX + c) mod m
# 
# X0 is arbitrary and referred to as the 'seed'.
# 
# A seed may be a specified value - this way the same 'random' sequence may be recreated at will, 
# this is appropriate if you wish to reproduce the same set of results twice - for instance, while debugging.
# 
# Alternatively a 'random' seed may be chosen.  
# A few standard sources of seed selection are:
#   X0 = date + time
#   X0 = precise time between two keystrokes
#   X0 = CRC of an arbitrary file
#   X0 = sample from a microphone
#   X0 = sample from 2.4Ghz wireless
#   X0 = /dev/urandom
# 
# m > 2^30
# 
# You may choose a precise power of two for 'm' to coincide with the word size of your computer (standardly 2^32).
# If you have a 32bit CPU and you choose 2^32, the modulo will be performed for free :)
# 
# If m is a precise power of two, choose 'a' such that:
# a mod 8 = 5
# 
# If m is a precise power of ten, choose a such that:
# a mod 200 = 21
# 
# 0.01m < a < 0.99m
# 
# This one's a bit wishy washy...
# "The binary and the decimal digits should offer no simple regular pattern."
# ...followed by...
# "One almost always obtains a reasonably good multiplier."
# ...it all started well i suppose!
# 
# 'c' is immaterial if 'a' is a good multiplier, except 'c' must have no factor in common with 'm'.  
# Thus we may choose c=1 or c=a.
# 
# The least significant digits/bits of 'X' will have lower entropy than the most significant digits/bits.
# ...therefore decisions based on 'X' should be influenced, primarily, by the MOST significant digits/bits.
# As such, it is best to consider 'X' as a random fraction:
# 0 <= X/m < 1
# ...EG. Visualise 'X' with a decimal point to its left.
# 
# 0 < X < m-1
# If you require a number in the range 0 < X < K-1, use:
# X = K(X/m)
# 
# Alternatively, Algorithm S:
# 1. records-selected-so-far:            m = 0
#    total-of-all-records-input-so-far:  t = 0
# 2. generate-random-number:             u = random
# 3. if (k-t)u >= n - m, goto (5)
# 4. m = m + 1
#    t = t + 1
#    if m < n, goto (2)
#    else success, our chosen random number is u
# 5. t = t + 1
#    goto (2)
# to paraphrase... "at first this equation looks dodgy, but if you run the numbers it's actually ok"
# 
# If you want to start applying "Euclids test" and "sprectral test" to advance your generator to 
# "monte carlo" standard I suggest you have a better grasp of maths than me and go and buy:
# -----------------------------------------------------------------------------
# - Seminumerical algorithms
# - The art of computer programming
# - Vol 2.
# - Addison Wesley
# - 3822
# - isbn: 0-201-03822-6
# -----------------------------------------------------------------------------
# ...This book also contains a whole host of other really interesting shit 
#    including: prime generation, prime factorings, polynomial analysis, 
#               discreet fourier transforms, cyclic convolution etc.
# 
# All information in this document was pilfed from this book and is, in itself, a summary of the summary.
#
#****************************************************************************** ****************************************
# I have NOT abusively tested this algorithm, or spent hours playing with {a, m, c} 
#
# But with: RNDm=$((0x100000000 -1)) .. RNDa=$((0x5D635DBA & 0xFFFFFFF0 | 5))  .. RNDc=1
# And a width of  4 [bits] {0..   15}, and a seed of     1234, the pattern repeats after 983,041 iterations :)
#       width of  8 [bits] {0..  255}, and a seed of     1234, the pattern repeats after 983,041 iterations :)
#     
#       width of  3 [bits] {0..    7}, and a seed of 19841984, the pattern repeats after 983,041 iterations :)
#       width of  8 [bits] {0..  255}, and a seed of 19841984, the pattern repeats after 983,041 iterations :)
#       width of 16 [bits] {0..65535}, and a seed of 19841984, the pattern repeats after 983,041 iterations :)
#     
# So, it looks like you're gonna get just shy of a million random numbers 
#   before it starts repeating - irrespective of the seed or output width
#

#------------------------------------------------------------------------------ ----------------------------------------
RNDm=$((0x100000000 -1))               # m: >2^30, precise ^2 allows for boolean optimisation
RNDa=$((0x5D635DBA & 0xFFFFFFF0 | 5))  # a: no binary pattern, as M is a ^2 A%8==5
RNDc=1                                 # c: no factor in common with m

# The wider (in bits) your result is, the less entropy will appear in the LSb's
RNDw=3                                 # w= width of result
RNDb=$((RNDr = 1 <<$RNDw, --RNDr))     # b= bitmask (variable (p)reuse)
RNDr=$((32 -$RNDw))                    # r= right shift amount

RNDs=$RANDOM                           # s= seed
RNDx=$RNDs                             # x= last sequence value
RNDn=$(($RNDx & $RNDm))                # n= most recent PRN

#+============================================================================= ========================================
RND() {  # ([seed, n])
	[[ $1 == seed ]] && {
		RNDs=$2
		RNDx=$RNDs
		return
	}

	local i=
	RNDx=$((i = $RNDa *$RNDx +$RNDc, i %$RNDm))  # x <- (ax+c)%m
	RNDn=$(($RNDx >>$RNDr))                      # upper bits have greater entropy

	return $RNDn
}

#+============================================================================= ========================================
RNDtest() {
	RND seed 19841984

	echo "RNDm=$RNDm"
	echo "RNDa=$RNDa"
	echo "RNDc=$RNDc"
	echo ""
	echo "RNDw=$RNDw"
	echo "RNDm=$RNDm"
	echo "RNDr=$RNDr"
	echo ""
	echo "RNDs=$RNDs"
	echo "RNDx=$RNDx"
	echo ""
	echo "RNDn=$RNDn"
	echo ""

	for ((i = 1000000;  i > 0;  i--)); do
		RND
		echo $RNDn
		[[ $(($i % 10000)) -eq 0 ]] && echo -en "\r$i " >&2
	done
	echo -e "\rdone    " >&2
}

#+============================================================================= ========================================
# main
#
RNDtest
exit 0
