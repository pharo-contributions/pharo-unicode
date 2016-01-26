"
I am CodePointToCharacterWriteStream. I wrap a Character WriteStream and translate code point Integers into Characters.

Here is an example

	String streamContents: [ :out |
		out unicodeCodePoints nextPutAll: (97 to: 122); nextPut: 33 ]
	
So client code writes Integer code points while the underlying stream receives Character objects.

In effect I translate each Integer code point to a Character.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #CodePointToCharacterWriteStream,
	#superclass : #Object,
	#instVars : [
		'writeStream'
	],
	#category : #'Unicode-Stream-Support'
}

{ #category : #initialization }
CodePointToCharacterWriteStream class >> on: characterWriteStream [
	^ self new
		on: characterWriteStream;
		yourself
]

{ #category : #streaming }
CodePointToCharacterWriteStream >> nextPut: codePoint [
	writeStream nextPut: (Character codePoint: codePoint)
]

{ #category : #streaming }
CodePointToCharacterWriteStream >> nextPutAll: collection [
	collection do: [ :each | self nextPut: each ]
]

{ #category : #initialization }
CodePointToCharacterWriteStream >> on: characterWriteStream [
	writeStream := characterWriteStream 
]
