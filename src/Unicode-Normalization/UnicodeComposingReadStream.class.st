"
I am UnicodeComposingReadStream. I wrap an input read stream of (normally decomposed) code points and produce a composed normalized stream of code points.

I use UnicodeComposer to compose intermediate buffers.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeComposingReadStream,
	#superclass : #Object,
	#instVars : [
		'input',
		'buffer',
		'first',
		'composer'
	],
	#category : #'Unicode-Normalization'
}

{ #category : #initialization }
UnicodeComposingReadStream class >> on: codePointReadStream [
	^ self new
		on: codePointReadStream;
		yourself
]

{ #category : #streaming }
UnicodeComposingReadStream >> atEnd [
	^ buffer isEmpty and: [ self isFirstEmpty and: [ input atEnd ] ]
]

{ #category : #private }
UnicodeComposingReadStream >> consumeFirst [
	| current |
	current := first.
	first := nil.
	^ current
]

{ #category : #initialization }
UnicodeComposingReadStream >> initialize [
	super initialize.
	buffer := OrderedCollection new.
	composer := UnicodeComposer default
]

{ #category : #private }
UnicodeComposingReadStream >> isFirstEmpty [
	^ first isNil or: [ first = #initialized ]
]

{ #category : #streaming }
UnicodeComposingReadStream >> next [
	self isFirstEmpty
		ifFalse: [ ^ self consumeFirst ].
	self shouldGetNextChunk 
		ifTrue: [ self nextChunk ].
	self isFirstEmpty
		ifFalse: [ ^ self consumeFirst ].
	buffer ifEmpty: [ ^ nil ].
	^ buffer removeFirst
]

{ #category : #private }
UnicodeComposingReadStream >> nextChunk [
	"Initialize when needed, try putting first starter in buffer"
	first = #initialized 
		ifFalse: [ 
			self scanFirstStarter 
				ifFalse: [ "Non-starter is in first" ^ self ] ].
	"buffer = <starter1>"
	[
		self scanUntilStarter.
		"buffer = <starter1> ... <starter2>"
		composer composeBuffer: buffer ] 
			doWhileFalse: [ buffer size > 1 or: [ input atEnd ] ]
	"There has to be more than one element in the buffer unless we're eof.
	Composition shrinks the buffer, sometimes recursively, but can need additional starters"

]

{ #category : #initialization }
UnicodeComposingReadStream >> on: codePointReadStream [
	input := codePointReadStream 
]

{ #category : #streaming }
UnicodeComposingReadStream >> peek [
	self isFirstEmpty
		ifFalse: [ ^ first ].
	self shouldGetNextChunk 
		ifTrue: [ self nextChunk ].
	self isFirstEmpty
		ifFalse: [ ^ first ].
	buffer ifEmpty: [ ^ nil ].
	^ buffer first
]

{ #category : #streaming }
UnicodeComposingReadStream >> reset [
	input reset.
	buffer removeAll
]

{ #category : #private }
UnicodeComposingReadStream >> scanFirstStarter [
	| current |
	"Find the first starter in input to use, put it in buffer and return true.
	Else put the non-starter in first and return false.
	Switch to #initialized once we've seen the first starter or when empty."
	input atEnd ifFalse: [ 
		current := input next.
		([ current unicodeCharacterData isStarter ] on: NotFound do: [ false ])
			ifTrue: [ 
				buffer addLast: current. 
				first := #initialized. 
				^ true ]
			ifFalse: [ 
				first := current. 
				^ false ] ].
	first := #inialized.
	^ false
]

{ #category : #private }
UnicodeComposingReadStream >> scanUntilStarter [
	| current |
	"Put non-starters and the next starter from input in the buffer, if any"
	[ input atEnd ] whileFalse: [ 
		current := input next.
		buffer addLast: current.
		([ current unicodeCharacterData isStarter ] on: NotFound do: [ false ])
			ifTrue: [ ^ self ] ]
]

{ #category : #private }
UnicodeComposingReadStream >> shouldGetNextChunk [
	"One element should remain in the buffer for the next iteration unless we're eof"
	
	^ buffer isEmpty or: [ buffer size = 1 and: [ input atEnd not] ]
]

{ #category : #converting }
UnicodeComposingReadStream >> unicodeCharacters [
	"Return a CharacterFromCodePointReadStream over the receiver that streams over Characters"
	
	^ CharacterFromCodePointReadStream on: self
]

{ #category : #streaming }
UnicodeComposingReadStream >> upToEnd [
	^ Array streamContents: [ :out |
			[ self atEnd ] whileFalse: [ out nextPut: self next ] ]
]
