"
Tests collation is implemented correctly according to Unicode algorithm under different weighing schemes,  using official test files.

The files are large, the tests are for the ordering of about 200,000 code point sequences, so expect them to take awhile.


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeDUCETCollateTests,
	#superclass : #TestCase,
	#category : #'Unicode-Tests-Collate'
}

{ #category : #resources }
UnicodeDUCETCollateTests class >> resources [
	^ {UnicodeCollateTestResource} 
]

{ #category : #private }
UnicodeDUCETCollateTests >> orderedCodePointsFrom: aHexString do: aBlock [
	| rs  codePoints |
	rs := aHexString readStream.
	"skip comments"
	[|p|
	(p := rs peek) = $# or: [ CharacterSet crlf includes: p]] 
		whileTrue: [ rs nextLine ].
	codePoints := OrderedCollection new.
	[|codePoint|
		codePoint := Number readFrom: rs base: 16.
		codePoints add: codePoint.
	(CharacterSet crlf includes: rs next)  ifTrue: [aBlock value: codePoints.
						codePoints := OrderedCollection new. ].
	rs atEnd] whileFalse
	
]

{ #category : #tests }
UnicodeDUCETCollateTests >> testNonIgnorableOrdering [
		
	| results |
	results := self 
		verifyOrdering: UnicodeCollateTestResource current getNonIgnorableRaw 		collateKeyGenerator: 
			[ :denormCodePointStream | | cks |
			cks := (CollateKeyStream on: denormCodePointStream).
			cks strategy nonIgnorable.
			cks  ] .
		self assert: results isEmpty
		
]

{ #category : #tests }
UnicodeDUCETCollateTests >> testShiftedOrdering [
		
	| results |
	results := self 
		verifyOrdering: UnicodeCollateTestResource current getShiftedRaw 		collateKeyGenerator: 
			[ :denormCodePointStream | | cks |
			cks := (CollateKeyStream on: denormCodePointStream).
			cks strategy shifted.
			cks  ] .
		self assert: results isEmpty
		
]

{ #category : #private }
UnicodeDUCETCollateTests >> verifyOrdering: rawOrderingData collateKeyGenerator: aKeyGenBlock [
	
	| errors prevKeyStream keyStream failCase |
	errors := OrderedCollection new.
	prevKeyStream := keyStream := nil.
	failCase :=  [errors add: prevKeyStream -> keyStream ].
	
	self orderedCodePointsFrom: rawOrderingData do: [: codePointSequence | 
		keyStream := aKeyGenBlock value: codePointSequence readStream unicodeNFD.
		prevKeyStream ifNotNil: [ [prevKeyStream <= keyStream ifFalse: failCase] on: Error do: failCase ].
		prevKeyStream := keyStream ].
		^errors
]
