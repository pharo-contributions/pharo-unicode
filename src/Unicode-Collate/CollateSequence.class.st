"
A CollateSequence is a sequence of Collate Elements.

Each collate element is stored as a word value, on the format: 
                                                
[level3][varWeigh][level2][level1]
[31,27 ][        26       ][ 25,16][ 15, 0  ].

If the DUCET or CLDR in newer versions go outside this range, adjustments to the class initialization will be necessary, hopefully 32bits will still be enough to sort the (strictly speaking, smaller) Unicode range.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #CollateSequence,
	#superclass : #Object,
	#type : #words,
	#classVars : [
		'LevelMasks',
		'LevelShifts',
		'VariableWeightMask'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'instance creation' }
CollateSequence class >> fromElements: collectionOfElements [
	^(self new: collectionOfElements size) initializeFrom: collectionOfElements
]

{ #category : #'class initialization' }
CollateSequence class >> initialize [
	"Each element in the DUCET has three levels.
	Use a word to store them all, masked and shifted as below.
	We use a bit to indicate whether the codepoint should be modified by variable weights."
	LevelShifts := #[0 16 26].
	LevelMasks := #(16rFFFF 16r1FF 16r3F).
	VariableWeightMask := 16r2000000
]

{ #category : #accessing }
CollateSequence >> at: anIndex level: aLevel [
	^(self at: anIndex) >> (LevelShifts at: aLevel) bitAnd: (LevelMasks at: aLevel) 
]

{ #category : #accessing }
CollateSequence >> at: anIndex putLevel1: level1 level2: level2 level3: level3 variableWeight: aBoolean [

	|collateElement|
	level1 > (LevelMasks at: 1) ifTrue: [ self error: 'Not enough room reserved for level1 collate values' ].
	level2 > (LevelMasks at: 2) ifTrue: [ self error: 'Not enough room reserved for level2 collate values' ].
	level3 > (LevelMasks at: 3) ifTrue: [ self error: 'Not enough room reserved for level3 collate values' ].
	collateElement := level1 << (LevelShifts at: 1).
	collateElement := collateElement + (level2 << (LevelShifts at: 2)).
	aBoolean ifTrue: [collateElement := collateElement bitOr: VariableWeightMask].
	collateElement := collateElement + (level3 << (LevelShifts at: 3)).

	self at: anIndex put: collateElement
	
]

{ #category : #accessing }
CollateSequence >> followedBy: anotherCodePoint [
	"A sequence is the single entry, no composition with other codepoints possible"
	^nil
]

{ #category : #'gt-inspector-extension' }
CollateSequence >> gtInspectorCollateSequenceIn: composite [
	<gtInspectorPresentationOrder: 40>
composite table
		title: 'Collate Elements';
		display: [
			
			(1 to: self size) collect: [:i | i -> (self printAt: i)]];
		column: 'Index' evaluated: #key;
		column: 'Collate Entry' evaluated: #value;
		send: [ :entry | 
				{(self at: entry key level: 1).
				 (self at: entry key level: 2).
				 (self at: entry key level: 3).} ].
			
]

{ #category : #'initialize - release' }
CollateSequence >> initializeFrom: elementCollection [
	"element = {level1. level2. level3. weight}"

	elementCollection
		withIndexDo:
			[ :element :index | 
			self
				at: index
				putLevel1: element first
				level2: element second
				level3: element third
				variableWeight: element last ]
]

{ #category : #private }
CollateSequence >> minimize [
	"A sequence is already a minimal element"
	^self
]

{ #category : #printing }
CollateSequence >> printAt: anIndex [
	^String streamContents: [ :s | self printAt: anIndex on: s ]
]

{ #category : #printing }
CollateSequence >> printAt: index on: aStream [
	aStream 
		nextPut: $[;
		nextPut: ((self variablyWeighedAt: index) ifTrue: [ $*] ifFalse: [$. ]).
	1 to: 3 do: [:level | |collateKey|
		collateKey := self at: index level: level.
		4 - (collateKey highBit // 4 + 1) timesRepeat: [aStream nextPut: $0].
		collateKey printOn: aStream base: 16.
		aStream nextPut: $. ].
	aStream skip: -1; nextPut: $] 
	
]

{ #category : #printing }
CollateSequence >> printOn: aStream [
	1 to: self size do: [ :i | self printAt: i on: aStream ]
	
]

{ #category : #accessing }
CollateSequence >> variablyWeighedAt: anIndex [
	^((self at: anIndex) bitAnd: VariableWeightMask) > 0
]
