"
I am CharacterToCodePointWriteStream. I wrap a code point Integer WriteStream and translate Characters to Integer code points.

Here is an example

	Array streamContents: [ :out |
		out unicodeCharacters nextPut: $A; nextPutAll: 'bcde' ]
	
So client code writes Characters and Strings while the underlying stream receives Integer code points,

In effect I translate each Character to an Integer code point.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #CharacterToCodePointWriteStream,
	#superclass : #Object,
	#instVars : [
		'writeStream'
	],
	#category : #'Unicode-Stream-Support'
}

{ #category : #initialization }
CharacterToCodePointWriteStream class >> on: codePointWriteStream [
	^ self new
		on: codePointWriteStream;
		yourself
]

{ #category : #streaming }
CharacterToCodePointWriteStream >> nextPut: character [
	writeStream nextPut: character codePoint
]

{ #category : #streaming }
CharacterToCodePointWriteStream >> nextPutAll: collection [
	collection do: [ :each | self nextPut: each ]
]

{ #category : #initialization }
CharacterToCodePointWriteStream >> on: codePointWriteStream [
	writeStream := codePointWriteStream 
]
