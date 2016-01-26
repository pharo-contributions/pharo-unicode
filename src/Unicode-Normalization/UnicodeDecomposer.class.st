"
I am UnicodeDecomposer. I decompose streams of Unicode code points using either Canonical or Compatible combinations, NFD and NFKD, using #decomposeFrom:to: and #decomposeCompatibleFrom:to:  respectively.

I use the Unicode Character Database to recursively decompose combined characters.

An alternative, streaming implementation of the process that I implement can be found in UnicodeDecomposingReadStream's two concrete subclasses.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDecomposer,
	#superclass : #Object,
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeDecomposer >> add: codePoint cccOrderedTo: buffer [
	| ccc index stop otherCCC |
	ccc := [ codePoint unicodeCharacterData ccc ] on: NotFound do: [ 0 ].
	index := buffer size.
	ccc = 0 
		ifFalse: [
			stop := false.
			[ index > 0 & stop not ] whileTrue: [ 
				otherCCC := [ (buffer at: index) unicodeCharacterData ccc ] on: NotFound do: [ 0 ].
				ccc < otherCCC
					ifTrue: [ index := index - 1 ]
					ifFalse: [ stop := true ] ] ].
	buffer add: codePoint afterIndex: index
]

{ #category : #private }
UnicodeDecomposer >> addCompatibleMapping: codePoint to: buffer [
	| ucd |
	ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [ nil ].
	(ucd notNil and: [ ucd hasDecomposition ])
		ifTrue: [ 
			ucd hasCanonicalDecomposition 
				ifTrue: [ 
					ucd decompositionMapping do: [ :each | 
						self addCompatibleMapping: each to: buffer ] ]
				ifFalse: [ 
					ucd decompositionMapping allButFirstDo: [ :each | 
						self addCompatibleMapping: each to: buffer ] ] ]
		ifFalse: [ self add: codePoint cccOrderedTo: buffer ]
]

{ #category : #private }
UnicodeDecomposer >> addMapping: codePoint to: buffer [
	| ucd |
	ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [ nil ].
	(ucd notNil and: [ ucd hasCanonicalDecomposition ])
		ifTrue: [ 
			ucd decompositionMapping do: [ :each | 
				self addMapping: each to: buffer ] ]
		ifFalse: [ self add: codePoint cccOrderedTo: buffer ]
]

{ #category : #private }
UnicodeDecomposer >> addNonStartersFrom: input to: buffer [
	| stop |
	stop := false.
	[ input atEnd | stop ] whileFalse: [ 
		([ input peek unicodeCharacterData isStarter not ] on: NotFound do: [ false ])
			ifTrue: [ self addMapping: input next to: buffer ]
			ifFalse: [ stop := true ] ]
]

{ #category : #public }
UnicodeDecomposer >> decomposeCompatibleFrom: input to: output [
	| buffer |
	buffer := OrderedCollection new.
	[ input atEnd ] whileFalse: [ 
		self addCompatibleMapping: input next to: buffer.
		self addNonStartersFrom: input to: buffer.
		"The additions to the buffer above were done respecting the CCC order, so we're done"
		output nextPutAll: buffer.
		buffer reset ]
]

{ #category : #public }
UnicodeDecomposer >> decomposeFrom: input to: output [
	| buffer |
	buffer := OrderedCollection new.
	[ input atEnd ] whileFalse: [ 
		self addMapping: input next to: buffer.
		self addNonStartersFrom: input to: buffer.
		"The additions to the buffer above were done respecting the CCC order, so we're done"
		output nextPutAll: buffer.
		buffer reset ]
]

{ #category : #convencience }
UnicodeDecomposer >> decomposeString: string [
	"Return the NFD of string, the canonical decomposition normal form"
	
	(string isByteString and: [ string isAsciiString ]) ifTrue: [
		"ACII strings are already in NFD" 
		^ string ]. 
	^ String streamContents: [ :out |
			self 
				decomposeFrom: string readStream unicodeCodePoints
				to: out unicodeCodePoints ]
]

{ #category : #convencience }
UnicodeDecomposer >> decomposeStringCompatible: string [
	"Return the NFKD of string, the compatible decomposition normal form"
	
	(string isByteString and: [ string isAsciiString ]) ifTrue: [
		"ACII strings are already in NFKD" 
		^ string ]. 
	^ String streamContents: [ :out |
			self 
				decomposeCompatibleFrom: string readStream unicodeCodePoints
				to: out unicodeCodePoints ]
]
