"
I am UnicodeNFKDReadStream. I implement NFKD, the compatible decomposed normal form.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeNFKDReadStream,
	#superclass : #UnicodeDecomposingReadStream,
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeNFKDReadStream >> addMappingFor: codePoint [
	| ucd |
	ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [ nil ].
	(ucd notNil and: [ ucd hasDecomposition ])
		ifTrue: [ 
			ucd decompositionMappingDo: [ :each | self addMappingFor: each  ] ]
		ifFalse: [ 
			self addToBufferCccOrdered: codePoint ]
]

{ #category : #private }
UnicodeNFKDReadStream >> isNonStarter: codePoint [
	"If we have a decomposition, we need to see if decomposed, we will be a nonStarter"
	| ucd |
	ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [ nil ].
	(ucd notNil and: [ ucd hasDecomposition ])
		ifTrue: [ 
			ucd decompositionMappingDo: [:onlyFirst | ^self isNonStarter: onlyFirst]]
		ifFalse: [ 
			^ucd isStarter not ]
]
