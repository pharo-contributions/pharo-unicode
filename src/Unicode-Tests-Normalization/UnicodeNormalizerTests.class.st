Class {
	#name : #UnicodeNormalizerTests,
	#superclass : #TestCase,
	#instVars : [
		'composer',
		'decomposer',
		'normalizer'
	],
	#category : #'Unicode-Tests-Normalization'
}

{ #category : #running }
UnicodeNormalizerTests >> setUp [
	normalizer := UnicodeNormalizer new.
	composer := UnicodeComposer default.
	decomposer := UnicodeDecomposer new
]

{ #category : #tests }
UnicodeNormalizerTests >> testAsciiIsAlwaysNormalized [
	| ascii nfc nfd nfkc nfkd |
	"ASCII strings are identical to all 4 normalization forms"
	ascii := String withAll: ((0 to: 127) collect: #asCharacter).
	"we have to circumvent the optimizations done in the convenience methods"
	nfc := ascii readStream unicodeCodePoints unicodeNFC unicodeCharacters upToEnd.
	self assert: nfc equals: ascii. 
	nfd := ascii readStream unicodeCodePoints unicodeNFD unicodeCharacters upToEnd.
	self assert: nfd equals: ascii. 
	nfkc := ascii readStream unicodeCodePoints unicodeNFKC unicodeCharacters upToEnd.
	self assert: nfkc equals: ascii. 
	nfkd := ascii readStream unicodeCodePoints unicodeNFKD unicodeCharacters upToEnd.
	self assert: nfkd equals: ascii
]

{ #category : #tests }
UnicodeNormalizerTests >> testFundamentalComposition [
	| in out |
	"LATIN SMALL LETTER E [U+0065] followed by COMBINING ACUTE ACCENT [U+0301]"
	in := #(101 769).
	out := Array streamContents: [ :writeStream |
		composer composeFrom: in readStream to: writeStream ].
	"LATIN SMALL LETTER E WITH ACUTE [U+00E9]"
	self assert: out equals: #(233)
]

{ #category : #tests }
UnicodeNormalizerTests >> testFundamentalDecomposition [
	| in out |
	"LATIN SMALL LETTER E WITH ACUTE [U+00E9]"
	in := #(233).
	out := Array streamContents: [ :writeStream |
		decomposer decomposeFrom: in readStream to: writeStream ].
	"LATIN SMALL LETTER E [U+0065] followed by COMBINING ACUTE ACCENT [U+0301]"
	self assert: out equals: #(101 769).
]

{ #category : #tests }
UnicodeNormalizerTests >> testHangul [
	"an lpart - vpart pair"
	self 
		assert: 16rAC1C unicodeCharacterData decompositionMapping 
		equals: #(16r1100 16r1162).
	self
		assert: (composer hangulCombinationOf: 16r1100 and: 16r1162)
		equals: 16rAC1C.	
	"an lpart - vpart - tpart triplet"
	self 
		assert: 16rD4DB unicodeCharacterData decompositionMapping 
		equals: #(16r1111 16r1171 16r11B6).
	self
		assert: (composer hangulCombinationOf: 16r1111 and: 16r1171 and: 16r11B6) 
		equals: 16rD4DB.
	"converting an lpart - vpart - tpart triplet in two steps"
	self
		assert: (composer hangulCombinationOf: 16r1111 and: 16r1171)
		equals: 16rD4CC.	
	self
		assert: (composer hangulCombinationOf: 16rD4CC and: 16r11B6)
		equals: 16rD4DB	

]

{ #category : #tests }
UnicodeNormalizerTests >> testLatin1IsAlwaysInNFC [
	| latin1 nfc |
	"Latin1 strings are identical to their NFC normalization form"
	latin1 := String withAll: ((0 to: 255) collect: #asCharacter).
	"we have to circumvent the optimizations done in the convenience methods"
	nfc := latin1 readStream unicodeCodePoints unicodeNFC unicodeCharacters upToEnd.
	self assert: nfc equals: latin1
]

{ #category : #tests }
UnicodeNormalizerTests >> testSimple [
	| original composed decomposed |
	original := 'les élèves Français'.
	decomposed := normalizer decomposeString: original.
	self assert: decomposed equals: 'les élèves Français'.
	composed := normalizer composeString: decomposed.
	self assert: composed equals: original.
	original := 'Düsseldorf Königsallee'.
	decomposed := normalizer decomposeString: original.
	self assert: decomposed equals: 'Düsseldorf Königsallee'.
	composed := normalizer composeString: decomposed.
	self assert: composed equals: original.
	
]
