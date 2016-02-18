"
I hold the contents of NormalizationTest.txt loaded from a URL.

  UnicodeNormalizationTestResource new setUp

http://www.unicode.org/Public/UNIDATA/NormalizationTest.txt

# Normalization Test Suite
# Format:
#
#   Columns (c1, c2,...) are separated by semicolons
#   They have the following meaning:
#      source; NFC; NFD; NFKC; NFKD
#   Comments are indicated with hash marks
#   Each of the columns may have one or more code points.
#
# CONFORMANCE:
# 1. The following invariants must be true for all conformant implementations
#
#    NFC
#      c2 ==  toNFC(c1) ==  toNFC(c2) ==  toNFC(c3)
#      c4 ==  toNFC(c4) ==  toNFC(c5)
#
#    NFD
#      c3 ==  toNFD(c1) ==  toNFD(c2) ==  toNFD(c3)
#      c5 ==  toNFD(c4) ==  toNFD(c5)
#
#    NFKC
#      c4 == toNFKC(c1) == toNFKC(c2) == toNFKC(c3) == toNFKC(c4) == toNFKC(c5)
#
#    NFKD
#      c5 == toNFKD(c1) == toNFKD(c2) == toNFKD(c3) == toNFKD(c4) == toNFKD(c5)
#
# 2. For every code point X assigned in this version of Unicode that is not specifically
#    listed in Part 1, the following invariants must be true for all conformant
#    implementations:
#
#      X == toNFC(X) == toNFD(X) == toNFKC(X) == toNFKD(X)
"
Class {
	#name : #UnicodeNormalizationTestResource,
	#superclass : #TestResource,
	#instVars : [
		'data'
	],
	#category : #'Unicode-Tests-Normalization'
}

{ #category : #running }
UnicodeNormalizationTestResource >> ccc0CharWithCCCDecompositionPrecededByHigherCCC [
	"Oh, tibetan...
	The only language with codepoints that have a combining class of 0, but a canonical decomposition of code points with ccc > 0.
 That these sort correctly when decomposed next to other CC > 0 is not tested by the official decomposition test file, so add a case for doing so here. These are also excluded for composition, see http://www.unicode.org/Public/8.0.0/ucd/CompositionExclusions.txt section 4"
"# 0F73 TIBETAN VOWEL SIGN II
 # 0F75 TIBETAN VOWEL SIGN UU
 # 0F81 TIBETAN VOWEL SIGN REVERSED II"

	^ SmallDictionary new
		at: #source put: #(16r0591 16r0F81);
		at: #NFC put: #(16r0F71 16r0F80 16r0591);
		at: #NFD put: #(16r0F71 16r0F80 16r0591);
		at: #NFKC put: #(16r0F71 16r0F80 16r0591);
		at: #NFKD put: #(16r0F71 16r0F80 16r0591);
		yourself
]

{ #category : #accessing }
UnicodeNormalizationTestResource >> data [
	"A collection of dictionaries with keys: #source #NFC #NFD #NFKC #NFKD and #comment"
	
	^ data
]

{ #category : #accessing }
UnicodeNormalizationTestResource >> normalizationTestFile [
	^ 'NormalizationTest.txt'
]

{ #category : #parsing }
UnicodeNormalizationTestResource >> parseLine: line [
	| columns test comment |
	columns := $; split: line.
	test := SmallDictionary new.
	#(#source #NFC #NFD #NFKC #NFKD) doWithIndex: [ :key :number | 
		| value |
		value := columns at: number.
		value := $  split: value.
		value := value collect: [ :each | Integer readFrom: each base: 16 ] as: Array.
		test at: key put: value ].
	comment := line copyFrom: (line indexOf: $#) + 2 to: line size.
	test at: #comment put: comment.
	^ test
]

{ #category : #running }
UnicodeNormalizationTestResource >> setUp [
	data := Array streamContents: [ :out | 
		(UnicodeCharacterData getUnicodeCharacterDatabaseRaw: self normalizationTestFile) linesDo: [ :line | 
			(line isEmpty or: [ line first = $# or: [ line first = $@ ] ])
				ifFalse: [ 
					| test |
					test := self parseLine: line.
					out nextPut: test ] ].
			out nextPut: self ccc0CharWithCCCDecompositionPrecededByHigherCCC ].

]
