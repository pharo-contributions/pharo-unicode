"
I am CharacterFromCodePointReadStream, I wrap a code point Integer ReadStream and translate code point Integers to Characters.

For example

	(97 to: 122) readStream 

is a ReadStream that returns Integers, while

	(97 to: 122) readStream unicodeCharacters
	
is a ReadStream that returns the Character objects for each code point.

	(97 to: 122) readStream unicodeCharacters upToEnd

In effect I translate each Integer code point to a Character.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #CharacterFromCodePointReadStream,
	#superclass : #Object,
	#instVars : [
		'readStream'
	],
	#category : #'Unicode-Stream-Support'
}

{ #category : #initialization }
CharacterFromCodePointReadStream class >> on: codePointReadStream [
	^ self new
		on: codePointReadStream;
		yourself
]

{ #category : #streaming }
CharacterFromCodePointReadStream >> atEnd [
	^ readStream atEnd
]

{ #category : #streaming }
CharacterFromCodePointReadStream >> next [
	^ readStream next ifNotNil: [ :codePoint | Character codePoint: codePoint ]
]

{ #category : #initialization }
CharacterFromCodePointReadStream >> on: codePointReadStream [
	readStream := codePointReadStream 
]

{ #category : #streaming }
CharacterFromCodePointReadStream >> peek [
	^ readStream peek ifNotNil: [ :codePoint | Character codePoint: codePoint ]
]

{ #category : #converting }
CharacterFromCodePointReadStream >> unicodeCodePoints [
	"Return a CodePointFromCharacterReadStream over the receiver that streams over Integer code points"
	
	^ CodePointFromCharacterReadStream on: self
]

{ #category : #streaming }
CharacterFromCodePointReadStream >> upToEnd [
	| out character |
	out := (String new: 10) writeStream.
	[ self atEnd ] whileFalse: [ 
		character := self next.
		(character isOctetCharacter not and: [ out originalContents isWideString not ])
			ifTrue: [ | position wideString |
				position := out position.
				wideString := WideString from: out originalContents.
				out on: wideString; setFrom: position + 1 to: position ].
		out nextPut: character ].
	^ out contents
]
