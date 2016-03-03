"
I am UnicodeDecomposer. I decompose streams of Unicode code points using either Canonical or Compatible combinations, NFD and NFKD, using #decomposeFrom:to: and #decomposeCompatibleFrom:to:  respectively.

I use the Unicode Character Database to recursively decompose combined characters.

An alternative, streaming implementation of the process that I implement can be found in UnicodeDecomposingReadStream's two concrete subclasses.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDecomposer,
	#superclass : #Object,
	#instVars : [
		'form'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeDecomposer >> decompose: inputStream to: outputStream [

	| buffer |
	form ifNil: 
		[ ^self error: 'decompose:to: should not be called directly' ].
	buffer := OrderedCollection new.
	[ inputStream atEnd ]
		whileFalse:
			[ form addMapping: inputStream next to: buffer.
			form addNonStartersFrom: inputStream to: buffer.
			"The additions to the buffer above were done respecting the CCC order, so we're done"
			outputStream nextPutAll: buffer.
			buffer reset ]
]

{ #category : #public }
UnicodeDecomposer >> decomposeCompatibleFrom: input to: output [

	form := UnicodeNFKD.
	self decompose: input to: output.
	
]

{ #category : #public }
UnicodeDecomposer >> decomposeFrom: input to: output [
	form := UnicodeNFD.
	self decompose: input to: output
]

{ #category : #convencience }
UnicodeDecomposer >> decomposeString: string [
	"Return the NFD of string, the canonical decomposition normal form"
	
	(string isByteString and: [ string isAsciiString ])
		ifTrue: ["ACII strings are already in NFD"
			 ^ string ].
	
	^ String
		streamContents:
			[ :out | 
			form := UnicodeNFD.
			self
				decompose: string readStream unicodeCodePoints
				to: out unicodeCodePoints ]
]

{ #category : #convencience }
UnicodeDecomposer >> decomposeStringCompatible: string [
	"Return the NFKD of string, the compatible decomposition normal form"
	
	(string isByteString and: [ string isAsciiString ]) 
		ifTrue: ["ACII strings are already in NFKD" 
			^ string ]. 
	^ String streamContents: [ :out |
			form := UnicodeNFKD.
			self 
				decompose: string readStream unicodeCodePoints
				to: out unicodeCodePoints ]
]
