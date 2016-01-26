"
I am UnicodeConcatenator, for a given normalization form I can concatenate two strings.

This implements the algorithm described in the last paragraph of section 9.1 Stable Code Points of http://www.unicode.org/reports/tr15/ Unicode Normalization.

Try:

  UnicodeConcatenator forNFC concatenateString: 'abce' with: '́def'.

  UnicodeConcatenator forNFC concatenateCodePoints: #(97 98 99 101) with: #(769 100 101 102).

The last character of the first string $e (U+0065 LATIN SMALL LETTER E) and the first character of the second string $́ (U+0301 COMBINING ACUTE ACCENT aka NON-SPACING ACUTE) combine to $é (U+00E9 LATIN SMALL LETTER E WITH ACUTE) in the resulting concatenation. 

Also note that both the first and second string had 4 characters, while their concatenation has 7. This is why concatenation of Unicode strings is non-trivial.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeConcatenator,
	#superclass : #Object,
	#instVars : [
		'property'
	],
	#classVars : [
		'Default'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #'instance creation' }
UnicodeConcatenator class >> forNFC [
	^ self new forNFC
]

{ #category : #'instance creation' }
UnicodeConcatenator class >> forNFD [
	^ self new forNFD
]

{ #category : #'instance creation' }
UnicodeConcatenator class >> forNFKC [
	^ self new forNFKC
]

{ #category : #'instance creation' }
UnicodeConcatenator class >> forNFKD [
	^ self new forNFKD
]

{ #category : #private }
UnicodeConcatenator >> codePointsToNFC: codePoints [
	^ codePoints readStream unicodeNFC upToEnd
]

{ #category : #private }
UnicodeConcatenator >> codePointsToNFD: codePoints [
	^ codePoints readStream unicodeNFD upToEnd
]

{ #category : #private }
UnicodeConcatenator >> codePointsToNFKC: codePoints [
	^ codePoints readStream unicodeNFKC upToEnd
]

{ #category : #private }
UnicodeConcatenator >> codePointsToNFKD: codePoints [
	^ codePoints readStream unicodeNFKD upToEnd
]

{ #category : #public }
UnicodeConcatenator >> concatenateCodePoints: first with: second [
	| lastStable firstStable middle result |
	first ifEmpty: [ ^ second ].
	second ifEmpty: [ ^ first ].
	lastStable := first findLast: self isStableCodePointBlock.
	lastStable = 0 ifTrue: [ lastStable := 1 ].
	firstStable := second findFirst: self isStableCodePointBlock.
	firstStable = 0 ifTrue: [ firstStable := second size ].
	(lastStable = first size and: [ firstStable = 1 ]) ifTrue: [ ^ first , second ].
	middle := (first copyFrom: lastStable to: first size) , (second copyFrom: 1 to: firstStable).
	middle := self normalizeCodePoints: middle.
	result := first class new: (lastStable - 1 + middle size + second size - firstStable).
	result 
		replaceFrom: 1 to: lastStable - 1 with: first startingAt: 1;
		replaceFrom: lastStable to: lastStable + middle size - 1 with: middle startingAt: 1;
		replaceFrom: lastStable + middle size to: result size with: second startingAt: firstStable + 1. 
	^ result
]

{ #category : #public }
UnicodeConcatenator >> concatenateString: first with: second [
	| lastStable firstStable middle result |
	first ifEmpty: [ ^ second ].
	second ifEmpty: [ ^ first ].
	lastStable := first findLast: self isStableCharacterBlock.
	lastStable = 0 ifTrue: [ lastStable := 1 ].
	firstStable := second findFirst: self isStableCodePointBlock.
	firstStable = 0 ifTrue: [ firstStable := second size ].
	(lastStable = first size and: [ firstStable = 1 ]) ifTrue: [ ^ first , second ].
	middle := (first copyFrom: lastStable to: first size) , (second copyFrom: 1 to: firstStable).
	middle := self normalizeString: middle.
	result := first class new: (lastStable - 1 + middle size + second size - firstStable).
	result 
		replaceFrom: 1 to: lastStable - 1 with: first startingAt: 1;
		replaceFrom: lastStable to: lastStable + middle size - 1 with: middle startingAt: 1;
		replaceFrom: lastStable + middle size to: result size with: second startingAt: firstStable + 1. 
	^ result

]

{ #category : #initalize }
UnicodeConcatenator >> forNFC [
	property := #NFC.
]

{ #category : #initalize }
UnicodeConcatenator >> forNFD [
	property := #NFD.
]

{ #category : #initalize }
UnicodeConcatenator >> forNFKC [
	property := #NFKC.
]

{ #category : #initalize }
UnicodeConcatenator >> forNFKD [
	property := #NFKD.
]

{ #category : #private }
UnicodeConcatenator >> isStableCharacterBlock [
	| quickCheckProperty |
	quickCheckProperty := self quickCheckProperty.
	^ [ :each | 
		([ each unicodeCharacterData isStarter ] on: NotFound do: [ true ]) 
			and: [ (NeoUnicodeCharacterData normalizationQuickCheck: quickCheckProperty forCodePoint: each codePoint) = #Y ] ]
]

{ #category : #private }
UnicodeConcatenator >> isStableCodePointBlock [
	| quickCheckProperty |
	quickCheckProperty := self quickCheckProperty.
	^ [ :each | 
		([ each unicodeCharacterData isStarter ] on: NotFound do: [ true ]) 
			and: [ (NeoUnicodeCharacterData normalizationQuickCheck: quickCheckProperty forCodePoint: each) = #Y ] ]
]

{ #category : #private }
UnicodeConcatenator >> normalizeCodePoints: codePoints [
	| method |
	method := (#codePointsTo, property) asSymbol asMutator.
	^ self perform: method with: codePoints 
]

{ #category : #private }
UnicodeConcatenator >> normalizeString: string [
	| method |
	method := (#stringTo, property) asSymbol asMutator.
	^ self perform: method with: string 
]

{ #category : #acccessing }
UnicodeConcatenator >> quickCheckProperty [
	^ (property , #'_QC') asSymbol
]

{ #category : #private }
UnicodeConcatenator >> stringToNFC: string [
	^ UnicodeNormalizer new toNFC: string
]

{ #category : #private }
UnicodeConcatenator >> stringToNFD: string [
	^ UnicodeNormalizer new toNFD: string
]

{ #category : #private }
UnicodeConcatenator >> stringToNFKC: string [
	^ UnicodeNormalizer new toNFKC: string
]

{ #category : #private }
UnicodeConcatenator >> stringToNFKD: string [
	^ UnicodeNormalizer new toNFKD: string
]
