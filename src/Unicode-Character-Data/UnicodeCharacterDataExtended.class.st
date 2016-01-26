"
I am UnicodeCharacterDataExtended, a subclass of UnicodeCharacterData.

I am an implementation detail, from an external viewpoint I am identical to my superclass.

Since many UCD entries (about 20K) have neither decomposition, case or numeric mappings, my superclass has no instance variables for these properties, but I do.


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeCharacterDataExtended,
	#superclass : #UnicodeCharacterData,
	#instVars : [
		'decompositionMapping',
		'numericMapping',
		'caseMapping'
	],
	#category : #'Unicode-Character-Data'
}

{ #category : #accessing }
UnicodeCharacterDataExtended >> caseMapping [
	"If not nil, a 3 element array: { upper. lower. title } each of which could be nil.
	Use the accessors #uppercase, #lowercase or #titlecase instead"
	
	^ caseMapping
]

{ #category : #accessing }
UnicodeCharacterDataExtended >> decompositionMapping [
	"Return my decomposition mapping if applicable, an array of code points, with an optional symbol tag in the first position. The code points of my decomposition can be combined into my codepoint."
	
	^ decompositionMapping
]

{ #category : #testing }
UnicodeCharacterDataExtended >> hasDecomposition [
	^ decompositionMapping notNil
]

{ #category : #private }
UnicodeCharacterDataExtended >> initializeCaseMappingFrom: fields [
	| uppercase lowercase titlecase |
	uppercase := (fields at: 13) ifEmpty: [ ] ifNotEmpty: [ :each | Integer readFrom: each base: 16 ].
	lowercase := (fields at: 14) ifEmpty: [ ] ifNotEmpty: [ :each | Integer readFrom: each base: 16 ].
	titlecase := (fields at: 15) ifEmpty: [ ] ifNotEmpty: [ :each | Integer readFrom: each base: 16 ].
	uppercase notNil | lowercase notNil | titlecase notNil
		ifTrue: [ caseMapping := Array with: uppercase with: lowercase with: titlecase ]
]

{ #category : #private }
UnicodeCharacterDataExtended >> initializeDecompositionMappingFrom: fields [
	decompositionMapping := fields sixth ifEmpty: [  ] ifNotEmpty: [ :mapping | self parseDecompositionMapping: mapping ]
]

{ #category : #initialize }
UnicodeCharacterDataExtended >> initializeFrom: fields [
	super initializeFrom: fields.
	self initializeDecompositionMappingFrom: fields.
	self initializeNumericMappingFrom: fields.
	self initializeCaseMappingFrom: fields
]

{ #category : #initialize }
UnicodeCharacterDataExtended >> initializeFromHangulSyllable: anInteger [ 
	"Derived from hangul syllable code point. 
	Ref. http://www.unicode.org/versions/Unicode8.0.0/ch03.pdf section 3.12 page 145, bottom part"

	| sIndex vIndex tIndex lIndex lPart vPart tPart |
	(self class isHangulSyllableCodePoint: anInteger)
		ifFalse: [ DomainError signal: 'Hangul syllable outside range' from: 16rAC00 to: 16rD7A3 ].
	"sBase := 16rAC00. lBase := 16r1100. vBase := 16r1161. tBase := 16r11A7.
	 lCount := 19. vCount := 21. tCount := 28. nCount := 588."
	codePoint := anInteger.
	sIndex := codePoint - 16rAC00.
	lIndex := sIndex // 588.
	vIndex := sIndex \\ 588 // 28.
	tIndex := sIndex \\ 28.
	lPart := 16r1100 + lIndex.
	vPart := 16r1161 + vIndex.
	tPart := 16r11A7 + tIndex.
	decompositionMapping := tIndex = 0 
		ifTrue: [ Array with: lPart with: vPart ] 
		ifFalse: [ Array with: lPart with: vPart with: tPart ] .
	name := decompositionMapping 
		inject: 'HANGUL SYLLABLE ' 
		into: [ :sub :next | sub , (self class jamoShortNames at: next) ].
	bitEncodedFields := 0 "CCC=0, General=#Lu, Bidi=#L, mirrored=false"
]

{ #category : #private }
UnicodeCharacterDataExtended >> initializeNumericMappingFrom: fields [
	| decimalDigitValue digitValue numericValue |
	decimalDigitValue := (fields at: 7) ifEmpty: [ ] ifNotEmpty: [ :each | each asNumber ]. 
	digitValue := (fields at: 8) ifEmpty: [ ] ifNotEmpty: [ :each | each asNumber ]. 
	numericValue := (fields at: 9) ifEmpty: [ ] ifNotEmpty: [ :each | each asNumber ].
	decimalDigitValue notNil | digitValue notNil | numericValue notNil
		ifTrue: [ numericMapping := Array with: decimalDigitValue with: digitValue with: numericValue ]
]

{ #category : #accessing }
UnicodeCharacterDataExtended >> numericMapping [
	"If not nil, a 3 element array: { decimalDigit. digit. numeric } each of which could be nil.
	Use the accessors #decimalDigitValue, #digitValue or #numericValue instead"

	^ numericMapping
]

{ #category : #private }
UnicodeCharacterDataExtended >> parseDecompositionMapping: string [
	^ ((Character space split: string)
			collect: [ :each |
				each first = $<
					ifTrue: [ (each copyFrom: 2 to: each size - 1) asSymbol ]
					ifFalse: [ Integer readFrom: each base: 16 ] ]) asArray
]
