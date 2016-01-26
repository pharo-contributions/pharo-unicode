"
I am UnicodeNFDReadStream. I implement NFD, the canonical decomposed normal form.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeNFDReadStream,
	#superclass : #UnicodeDecomposingReadStream,
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeNFDReadStream >> addMappingFor: codePoint [
	| ucd |
	ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [ nil ].
	(ucd notNil and: [ ucd hasCanonicalDecomposition ])
		ifTrue: [ 
			ucd decompositionMappingDo: [ :each | self addMappingFor: each ] ]
		ifFalse: [ 
			self addToBufferCccOrdered: codePoint ]
]
