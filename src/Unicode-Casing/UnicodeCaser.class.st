"
I am UnicodeCaser, a tool to change the case of a string of Unicode characters to lower, upper or title case.

Currently, this implementation is too simplistic.


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeCaser,
	#superclass : #Object,
	#category : #'Unicode-Casing'
}

{ #category : #public }
UnicodeCaser >> case: case from: inputStream to: outputStream [
	self assert: (#(uppercase lowercase titelcase) includes: case).
	inputStream do: [ :each |
		| unicodeCharacterData |
		unicodeCharacterData := NeoUnicodeCharacterData forCodePoint: each.
		(unicodeCharacterData perform: case)
			ifNil: [ outputStream nextPut: each ] 
			ifNotNil: [ :value | outputStream nextPut: value ] ]
]

{ #category : #public }
UnicodeCaser >> case: case fromCharacters: inputStream to: outputStream [
	self assert: (#(uppercase lowercase titelcase) includes: case).
	inputStream do: [ :each |
		(each unicodeCharacterData perform: case)
			ifNil: [ outputStream nextPut: each ] 
			ifNotNil: [ :value | outputStream nextPut: (Character codePoint: value) ] ]
]

{ #category : #convencience }
UnicodeCaser >> case: case string: string [
	^ String streamContents: [ :out |
			self case: case fromCharacters: string readStream to: out ]
]
