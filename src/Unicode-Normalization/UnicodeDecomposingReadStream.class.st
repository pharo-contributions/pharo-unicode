"
I am UnicodeDecomposingReadStream. I wrap an input read stream of code points and produce a decomposed normalized stream of code points. I am abstract.

An alternative, non-streaming implementation of the process that I implement can be found in UnicodeDecomposer.

My two concrete subclasses implement Canonical and Compatible decomposition.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDecomposingReadStream,
	#superclass : #Object,
	#instVars : [
		'input',
		'buffer'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #initialization }
UnicodeDecomposingReadStream class >> on: codePointReadStream [
	^ self new
		on: codePointReadStream;
		yourself
]

{ #category : #private }
UnicodeDecomposingReadStream >> add: codePoint cccOrderedTo: buffer [
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
UnicodeDecomposingReadStream >> addMappingFor: codePoint [
	"Recursively expand codePoint to buffer"
	self subclassResponsibility
]

{ #category : #private }
UnicodeDecomposingReadStream >> addNonStarters [
	"Peek forward for additional non-starters and add them to buffer, if any"
	| stop |
	stop := false.
	[ input atEnd | stop ] whileFalse: [ 
		([ input peek unicodeCharacterData isStarter not ] on: NotFound do: [ false ])
			ifTrue: [ self addMappingFor: input next ]
			ifFalse: [ stop := true ] ]
]

{ #category : #streaming }
UnicodeDecomposingReadStream >> atEnd [
	^ buffer isEmpty and: [ input atEnd ]
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
			self addMappingFor: input next.
			self addNonStarters.
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
