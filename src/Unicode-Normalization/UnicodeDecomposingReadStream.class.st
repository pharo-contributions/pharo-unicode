"
UnicodeDecomposingReadStream  is a streaming implementation of  the Unicode Normalization Algorithm for the Decomposed Forms.
It wraps an input read stream of code points and produces a  stream of code points in the decomposed  form the stream was created as. 

An  alternate implementation of the same, operating on strings, rather than streams, can be found in UnicodeDecomposer.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDecomposingReadStream,
	#superclass : #Object,
	#instVars : [
		'input',
		'buffer',
		'form'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #initialization }
UnicodeDecomposingReadStream class >> form: aDecomposedNormalizationForm on: codePointReadStream [
	^ self new
		form: aDecomposedNormalizationForm on: codePointReadStream;
		yourself
]

{ #category : #initialization }
UnicodeDecomposingReadStream class >> nfdFormOn: codePointReadStream [
	^ self 
		form: UnicodeNFD
		on: codePointReadStream
]

{ #category : #initialization }
UnicodeDecomposingReadStream class >> nfkdFormOn: codePointReadStream [
	^ self 
		form: UnicodeNFKD
		on: codePointReadStream
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> atEnd [
	^ buffer isEmpty and: [ input atEnd ]
]

{ #category : #initialization }
UnicodeDecomposingReadStream >> form: aDecomposedNormalizationForm on: codePointReadStream [
	form := aDecomposedNormalizationForm.
	input := codePointReadStream 
]

{ #category : #initialization }
UnicodeDecomposingReadStream >> initialize [
	super initialize.
	buffer := OrderedCollection new
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> next [
	buffer ifEmpty: [ self nextChunk ].
	buffer ifEmpty: [ ^ nil ].
	^ buffer removeFirst
]

{ #category : #private }
UnicodeDecomposingReadStream >> nextChunk [
	input atEnd
		ifFalse: [  
			form addMapping: input next to: buffer.
			form addNonStartersFrom: input to: buffer.
			"The additions to the buffer above were done respecting the CCC order, so we're done" ]
]

{ #category : #initialization }
UnicodeDecomposingReadStream >> on: codePointReadStream [
	input := codePointReadStream 
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> peek [
	buffer ifEmpty: [ self nextChunk ].
	buffer ifEmpty: [ ^ nil ].
	^ buffer first
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> reset [
	input reset.
	buffer removeAll
]

{ #category : #converting }
UnicodeDecomposingReadStream >> unicodeCharacters [
	"Return a CharacterFromCodePointReadStream over the receiver that streams over Characters"
	
	^ CharacterFromCodePointReadStream on: self
]

{ #category : #converting }
UnicodeDecomposingReadStream >> unicodeCompose [
	"Return a NeoUnicodeComposingReadStream over the receiver that streams over Integer code points after composing them"
	
	^ UnicodeComposingReadStream on: self
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> upToEnd [
	^ Array streamContents: [ :out |
			[ self atEnd ] whileFalse: [ out nextPut: self next ] ]
]
