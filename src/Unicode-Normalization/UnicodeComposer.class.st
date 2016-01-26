"
I am UnicodeComposer. I compose streams of unicode code points to their composed form.

I have two primary interfaces.

The first is #composeFrom:to: that operates from an input stream of code points to an output stream of code points in one process.

The second is #composeBuffer: the elementary operation of the above process that operates on a buffer of non-starters between a first and final starter. Note that this buffer can shrink.

Streaming composition can be done by UnicodeComposingReadStream that uses me for buffer composition.

I can only work 100% correct if my input is properly decomposed. 

If my input is NFD, my output will be NFC. 
If my input is NFKD, my output will be NFKC.

I know how to do algorithmic composition of Hangul.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeComposer,
	#superclass : #Object,
	#instVars : [
		'combinations',
		'combiningCharacters'
	],
	#classVars : [
		'Default'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #accessing }
UnicodeComposer class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : #accessing }
UnicodeComposer class >> resetDefault [
	Default := nil
]

{ #category : #'private - combinations' }
UnicodeComposer >> combinationOf: first and: second [
	second ifNil: [ ^ nil ].
	^ (self hangulCombinationOf: first and: second) 
			ifNil: [ self primaryCombinationOf: first and: second ]
]

{ #category : #accessing }
UnicodeComposer >> combinations [
	combinations ifNil: [ self initializeForComposition ].
	^ combinations
]

{ #category : #accessing }
UnicodeComposer >> combiningCharacters [
	combiningCharacters ifNil: [ self initializeForComposition ].
	^ combiningCharacters
]

{ #category : #public }
UnicodeComposer >> composeBuffer: buffer [	
	"Process decomposed CCC ordered buffer, trying to combine/compose pairs, unless blocked"
	| lastCCC index ccc combination |
	lastCCC := 0.
	index := 2.
	[ index <= buffer size ] whileTrue: [
		ccc := [ (buffer at: index) unicodeCharacterData ccc ] on: NotFound do: [ 0 ].
		combination := self combinationOf: buffer first and: (buffer at: index).
		(combination notNil and: [ (lastCCC < ccc) | (lastCCC = 0) ])
			ifTrue: [ 
				buffer at: 1 put: combination.
				buffer removeAt: index ]
			ifFalse: [ 
				index := index + 1. 
				lastCCC := ccc ] ]
]

{ #category : #public }
UnicodeComposer >> composeFrom: input to: output [
	| buffer |
	buffer := OrderedCollection new.
	(self scanForStarterFrom: input to: output)
		ifNotNil: [ :nonStarter | buffer addLast: nonStarter ].
	[ input atEnd ] whileFalse: [
		self scanUntilStarterFrom: input to: buffer.
		"Compose the buffer <starter1> ... <starter2>" 
		self composeBuffer: buffer.
		"We're done, flush everything except <starter2> which we keep for the next iteration"
		buffer allButLastDo: [ :each | output nextPut: each ].
		buffer last in: [ :last | buffer reset; addLast: last ] ].
	output nextPutAll: buffer
]

{ #category : #convencience }
UnicodeComposer >> composeString: string [
	"Return the NFC of string, the canonical composition normal form"
	
	string isByteString ifTrue: [
		"Latin1 strings are already in NFC" 
		^ string ]. 
	^ String streamContents: [ :out |
			self 
				composeFrom: string readStream unicodeCodePoints
				to: out unicodeCodePoints ]
]

{ #category : #'private - combinations' }
UnicodeComposer >> hangulCombinationOf: first and: second [
	"Algorithmic Hangul Syllable Componsition.
	Ref. http://www.unicode.org/versions/Unicode8.0.0/ch03.pdf section 3.12 page 146"
	
	(self hangulLVCombinationOf: first and: second)
		ifNotNil: [ :combination | ^ combination ].
	(self hangulSTCombinationOf: first and: second)
		ifNotNil: [ :combination | ^ combination ].
	^ nil
]

{ #category : #'private - combinations' }
UnicodeComposer >> hangulCombinationOf: lPart and: vPart and: tPart [
	"Algorithmic Hangul Syllable Componsition.
	Ref. http://www.unicode.org/versions/Unicode8.0.0/ch03.pdf section 3.12 page 146"
	
	| lIndex vIndex tIndex |
	"sBase := 16rAC00. lBase := 16r1100. vBase := 16r1161. tBase := 16r11A7.
   nCount := 588. tCount := 28."
	^ ((lPart between: 16r1100 and: 16r1112) 
			and: [ (vPart between: 16r1161 and: 16r1175)
				and: [ tPart between: 16r11A7 and: 16r11C2 ] ])
				ifTrue: [ 
					lIndex := lPart - 16r1100.
					vIndex := vPart - 16r1161.
					tIndex := tPart - 16r11A7.
					16rAC00 + (lIndex * 588) + (vIndex * 28) + tIndex ]
]

{ #category : #'private - combinations' }
UnicodeComposer >> hangulLVCombinationOf: lPart and: vPart [
	"Algorithmic Hangul Syllable Componsition.
	Ref. http://www.unicode.org/versions/Unicode8.0.0/ch03.pdf section 3.12 page 146"
	
	| lIndex vIndex |
	"sBase := 16rAC00. lBase := 16r1100. vBase := 16r1161.
   nCount := 588. tCount := 28."
	^ ((lPart between: 16r1100 and: 16r1112) 
		and: [ vPart between: 16r1161 and: 16r1175 ])
			ifTrue: [ 
				lIndex := lPart - 16r1100.
				vIndex := vPart - 16r1161.
				^ 16rAC00 + (lIndex * 588) + (vIndex * 28) ]
]

{ #category : #'private - combinations' }
UnicodeComposer >> hangulSTCombinationOf: sPart and: tPart [
	"Algorithmic Hangul Syllable Componsition.
	Ref. http://www.unicode.org/versions/Unicode8.0.0/ch03.pdf section 3.12 page 146"
	
	| tIndex |
	"sBase := 16rAC00. lBase := 16r1100. vBase := 16r1161.
   nCount := 588. tCount := 28."
	^ ((sPart between: 16rAC00 and: 16rD7A3)
		and: [ (tPart between: 16r11A7 and: 16r11C2)
			and: [ sPart - 16rAC00 \\ 28 = 0 ] ])
			ifTrue: [ 
				tIndex := tPart - 16r11A7.
				sPart + tIndex ]
]

{ #category : #initialize }
UnicodeComposer >> initializeForComposition [
	combinations := IdentityDictionary new.
	combiningCharacters := IdentitySet new.
	UnicodeCharacterData database valuesDo: [ :each |
		each isPrimaryComposite ifTrue: [ | combination |
			combination := each decompositionMapping.
			"combination first + combination second = each codePoint"
			combinations 
				at: combination first 
				ifPresent: [ :value | 
					value at: combination second put: each codePoint ]
				ifAbsent: [ | value |
					value := IdentityDictionary new at: combination second put: each codePoint; yourself.
					combinations at: combination first put: value ].
			combiningCharacters add: combination second ] ]
]

{ #category : #testing }
UnicodeComposer >> isCombiningCharacter: codePoint [
	^ self combiningCharacters includes: codePoint
]

{ #category : #'private - combinations' }
UnicodeComposer >> primaryCombinationOf: first and: second [
	"Resolve Primary Composition using inverse computed table"
	
	^ (self isCombiningCharacter: second)
			ifTrue: [ 
				self combinations 
					at: first 
					ifPresent: [ :compositions | 
						compositions at: second ifAbsent: [ ] ] 
					ifAbsent: [ ] ]
]

{ #category : #private }
UnicodeComposer >> scanForStarterFrom: input to: output [
	| current |
	"Find the first starter in input and return it, else copy to output"
	[ input atEnd ] whileFalse: [ 
		current := input next.
		([ current unicodeCharacterData isStarter ] on: NotFound do: [ false ])
			ifTrue: [ ^ current ]
			ifFalse: [ output nextPut: current ] ].
	^ nil
]

{ #category : #private }
UnicodeComposer >> scanUntilStarterFrom: input to: buffer [
	| current |
	"Put non-starters and the next starter from input in the buffer, if any"
	[ input atEnd ] whileFalse: [ 
		current := input next.
		buffer addLast: current.
		([ current unicodeCharacterData isStarter ] on: NotFound do: [ false ])
			ifTrue: [ ^ self ] ]
]
