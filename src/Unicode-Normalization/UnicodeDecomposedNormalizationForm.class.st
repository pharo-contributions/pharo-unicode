"
I am a Decomposed Normalization Form.
I know how to perform the two main steps of the Unicode decomposition algorithm: 
- Recursively decompose a code point into a buffer
- Recursively decompose a stream of non-starter codepoints into a buffer.

These operations rely on no state, and as such are implemented on the class side.
For pure string operations, decompose

http://unicode.org/reports/tr15/#Description_Norm

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDecomposedNormalizationForm,
	#superclass : #Object,
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeDecomposedNormalizationForm class >> add: codePoint cccOrderedTo: buffer [
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

{ #category : #conversion }
UnicodeDecomposedNormalizationForm class >> addMapping: codePoint to: buffer [
	(self decompositionEntryOf: codePoint)
		ifNotNil: [ :entry | entry decompositionMappingDo: [ :each | self addMapping: each to: buffer]]
		ifNil: [ self add: codePoint cccOrderedTo: buffer ]
]

{ #category : #conversion }
UnicodeDecomposedNormalizationForm class >> addNonStartersFrom: input to: buffer [
	| stop |
	stop := false.
	[ input atEnd | stop ] whileFalse: [ 
		([ self isNonStarter: input peek ] on: NotFound do: [ false ])
			ifTrue: [ self addMapping: input next to: buffer ]
			ifFalse: [ stop := true ] ]
]

{ #category : #private }
UnicodeDecomposedNormalizationForm class >> decompositionEntryOf: aCodePoint [
	"Return a UnicodeCharacterDate instance that holds the decomposition mapping I care about for aCodePoint"
	^self subclassResponsibility 
]

{ #category : #private }
UnicodeDecomposedNormalizationForm class >> isNonStarter: codePoint [
	"If we have a decomposition, we need to see if decomposed, we will be a nonStarter.
	Assume there is no decomposition on form NonStarter,*,Starter,* (which would make very little sense...)"

	(self decompositionEntryOf: codePoint)
		ifNotNil: [ :entry | entry decompositionMappingDo: [ :onlyFirst | ^ self isNonStarter: onlyFirst ] ]
		ifNil:
			[ | ucd |
			ucd := [ codePoint unicodeCharacterData ] on: NotFound do: [nil].
			^ucd notNil and: [ ucd isStarter not ] ].
]
