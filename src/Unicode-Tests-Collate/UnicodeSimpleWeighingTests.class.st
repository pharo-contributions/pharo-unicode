"
I implement a few tests for the weighings that are not extensively covered by the Unicode test files, using Table 12 from Technical Report 10.

http://unicode.org/reports/tr10/#Variable_Weighting


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeSimpleWeighingTests,
	#superclass : #TestCase,
	#category : #'Unicode-Tests-Collate'
}

{ #category : #data }
UnicodeSimpleWeighingTests >> blankedOrder [
 ^#(
'death'
'de luge'
'de-luge'
'deluge'
'de-luge'
'de Luge'
'de-Luge'
'deLuge'
'de-Luge'
'demark')
]

{ #category : #data }
UnicodeSimpleWeighingTests >> blankedSymbolOrder [
^#(
'☠happy'
'♡happy'
'☠sad'
'♡sad'
)
]

{ #category : #data }
UnicodeSimpleWeighingTests >> shiftTrimmedOrder [
^#(
'death'
'deluge'
'de luge'
'de-luge'
'de-luge'
'deLuge'
'de Luge'
'de-Luge'
'de-Luge'
'demark'
)
]

{ #category : #data }
UnicodeSimpleWeighingTests >> shiftTrimmedSymbolOrder [
^#(
'☠happy'
'♡happy'
'☠sad'
'♡sad'
)
]

{ #category : #helper }
UnicodeSimpleWeighingTests >> test: anOrder conformsTo: aWeighingSelector [
	|collateStreams|

	collateStreams := anOrder collect: [ :each | CollateKeyStream on: each readStream unicodeCodePoints unicodeNFD ].
	collateStreams do: [ :each | each strategy perform: aWeighingSelector].
	2 to: collateStreams size do: [:i | 
		self assert: (collateStreams at: i - 1) < (collateStreams at: i)] 
]

{ #category : #helper }
UnicodeSimpleWeighingTests >> test: anOrder withWeighing: aSymbol [
	|collateStreams|

	collateStreams := anOrder collect: [ :each | CollateKeyStream on: each unicodeCodePoints unicodeNFD ].
	collateStreams do: [ :each | each strategy perform: aSymbol].
	2 to: collateStreams size do: [:i | 
		self assert: (collateStreams at: i - 1) < (collateStreams at: i)] 
]

{ #category : #tests }
UnicodeSimpleWeighingTests >> testBlankedOrdering [
	self test: self blankedOrder conformsTo: #blanked
]

{ #category : #tests }
UnicodeSimpleWeighingTests >> testBlankedSymbolOrdering [
	self test: self blankedSymbolOrder conformsTo: #blanked
]

{ #category : #tests }
UnicodeSimpleWeighingTests >> testShiftTrimmedOrdering [
	self test: self shiftTrimmedOrder conformsTo: #shiftTrimmed
]

{ #category : #tests }
UnicodeSimpleWeighingTests >> testShiftTrimmedSymbolOrdering [
	self test: self shiftTrimmedSymbolOrder conformsTo: #shiftTrimmed
]
