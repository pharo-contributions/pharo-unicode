"
I am CodePointFromCharacterReadStream, I wrap a Character ReadStream and translate Characters into code point Integers.

For example

	'abc' readStream 

is a ReadStream that returns Character objects, while

	'abc' readStream unicodeCodePoints
	
is a ReadStream that returns the Integer code points of each character.

	Character alphabet  readStream unicodeCodePoints upToEnd

In effect I translate each Character to an Integer code point.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #CodePointFromCharacterReadStream,
	#superclass : #Object,
	#instVars : [
		'readStream'
	],
	#category : #'Unicode-Stream-Support'
}

{ #category : #initialization }
CodePointFromCharacterReadStream class >> on: characterReadStream [
	^ self new
		on: characterReadStream;
		yourself
]

{ #category : #streaming }
CodePointFromCharacterReadStream >> atEnd [
	^ readStream atEnd
]

{ #category : #streaming }
CodePointFromCharacterReadStream >> next [
	^ readStream next ifNotNil: [ :character | character codePoint ]
]

{ #category : #initialization }
CodePointFromCharacterReadStream >> on: characterReadStream [
	readStream := characterReadStream 
]

{ #category : #streaming }
CodePointFromCharacterReadStream >> peek [
	^ readStream peek ifNotNil: [ :character | character codePoint ]
]

{ #category : #streaming }
CodePointFromCharacterReadStream >> reset [
	^ readStream reset
]

{ #category : #converting }
CodePointFromCharacterReadStream >> unicodeCharacters [
	"Return a CharacterFromCodePointReadStream over the receiver that streams over Characters"
	
	^ CharacterFromCodePointReadStream on: self
]

{ #category : #streaming }
CodePointFromCharacterReadStream >> upToEnd [
	^ Array streamContents: [ :out |
			[ self atEnd ] whileFalse: [ out nextPut: self next ] ]
]
