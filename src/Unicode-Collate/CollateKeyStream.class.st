"
CollateKeyStream provides a stream on the collate key  of a normalized string.

In the string , each codepoint or codepoint sequence for which a collate entry is defined, is mapped to a collate sequence.
This sequence contains values on up to four levels; a collate key contains all the nonzero values on each level, separated by zeroes.

See http://unicode.org/reports/tr10/#Step_3 for details.

"
Class {
	#name : #CollateKeyStream,
	#superclass : #Object,
	#instVars : [
		'strategy',
		'nfdStream',
		'buffer',
		'level'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'instance creation' }
CollateKeyStream class >> on: anNKDStream [
	^self new initializeOn: anNKDStream
]

{ #category : #comparison }
CollateKeyStream >> < anotherKeyStream [
								
	^(self collateTo: anotherKeyStream) < 0
]

{ #category : #comparison }
CollateKeyStream >> <= anotherKeyStream [					
	^(self collateTo: anotherKeyStream) <= 0
]

{ #category : #comparison }
CollateKeyStream >> = anotherKeyStream [
								
	^(self collateTo: anotherKeyStream) = 0
]

{ #category : #comparison }
CollateKeyStream >> > anotherKeyStream [
								
	^(self collateTo: anotherKeyStream) > 0
]

{ #category : #comparison }
CollateKeyStream >> >= anotherKeyStream [
								
	^(self collateTo: anotherKeyStream) >= 0
]

{ #category : #comparison }
CollateKeyStream >> collateTo: anotherKeyStream [
	"return -1 if I am before anotherKeyStream, 0 if we are equal, and 1 if I am after"
	| a b |
	self strategy = anotherKeyStream strategy ifFalse: [ self error: 'Collating two sequences with different strategies is nonsensical' ].
	self reset.
	anotherKeyStream reset.
	[(a := self next) = (b := anotherKeyStream next) and: [b notNil]] whileTrue.
	^a ifNil:    [ b ifNil: [0] ifNotNil: [ 1] ]
		ifNotNil: [b ifNil: [-1] ifNotNil: [
				a < b ifTrue: [-1]
						ifFalse: [a = b ifTrue: [0]
											 ifFalse: [1]]]].
]

{ #category : #private }
CollateKeyStream >> fillBuffer [
	"Read the next collate element into buffer"

	| entry nonStarters ccValue  |
	ccValue := [ :codePoint :previousCCC| 
		"http://unicode.org/reports/tr10/#S2.1.2
		Return codePoint ccc if it is unblocked by current ccValue, 0 if blocked"
		(UnicodeCharacterData forCodePoint: codePoint ifAbsent: nil) 
			ifNotNil: [ :data | data ccc > previousCCC ifTrue: [ data ccc ] ifFalse: [ 0 ] ] ifNil: [ 0 ] ].
	nfdStream next
		ifNil: [ "Go to next level, or fill buffer with nils to return indicating end of stream"
			level < strategy weight levels
				ifTrue: [buffer add: 0.
					level := level + 1.
					nfdStream reset.
					entry := strategy collateEntryFor: nfdStream next ]
				ifFalse: [^buffer add: nil; add: nil ] ]
		ifNotNil: [ :codePoint | entry := strategy collateEntryFor: codePoint ].
	"Resolve combined entries. A combination is either a sequence of starters, or a sequence of starters ending in combining marks. Combining marks are special; the first one that has a combination will be used. See http://unicode.org/reports/tr10/#S2.1 "
	
	nonStarters := OrderedCollection new.
	[|	match candidate currentCCC |
		currentCCC := 0.
		candidate := nfdStream peek.
		currentCCC := ccValue value: candidate value: currentCCC.
		currentCCC > 0 
			ifFalse: [
				 (match := entry followedBy: candidate) 
					ifNotNil: [ :e | nfdStream next.
						entry := e ]]
			ifTrue: [[ currentCCC > 0 ] whileTrue: 
				[	(match := entry followedBy: candidate) 
						ifNotNil: [ :e | entry := e ]
						ifNil: [ |cccBaseIx|
							cccBaseIx := 1.
							[ cccBaseIx <= nonStarters size and: [ candidate notNil] ] whileTrue: [ 
								((nonStarters at: cccBaseIx) followedBy: candidate) 
									ifNotNil: [:cccContraction |
										nonStarters at: cccBaseIx put: cccContraction.
										candidate := nil].
								cccBaseIx := cccBaseIx + 1].
							candidate ifNotNil: [nonStarters add: (strategy collateEntryFor:candidate)] ]. 	
					candidate := nfdStream next; peek.
					currentCCC := ccValue value: candidate value: currentCCC]].
		 match notNil and: [nonStarters isEmpty]]  whileTrue.
	
	"addLevel:in:precededBy:to: returns the number of values added to buffer.
	(Collate entries with value 0 are not part of key). If no values are actually added, call fillBuffer again."
	"TODO: Check that no weigings does alterations on the boundaries we fill buffer, so nil can be used safely for first element "
	(nonStarters
		inject: (strategy weight addLevel: level in: entry precededBy: nil to: buffer)
		into: [ :sub :next | sub + (strategy weight addLevel: level in: (entry := next) precededBy: entry to: buffer) ]) = 0
		ifTrue: [ self fillBuffer ] 
]

{ #category : #'initialize-release' }
CollateKeyStream >> initialize [
	strategy := CollateStrategy default.
	buffer := OrderedCollection new.
	level := 1.
]

{ #category : #'initialize-release' }
CollateKeyStream >> initializeOn: anNKDStream [

	nfdStream := anNKDStream.
]

{ #category : #accessing }
CollateKeyStream >> next [
	buffer isEmpty ifTrue: [ self peek].
	^buffer isEmpty ifFalse: [ buffer removeFirst ]
]

{ #category : #accessing }
CollateKeyStream >> peek [
	[buffer size < 2] whileTrue: [ self fillBuffer].  
	^buffer at: 2 
]

{ #category : #accessing }
CollateKeyStream >> reset [
	level := 1.

	nfdStream reset.
	buffer removeAll.
]

{ #category : #accessing }
CollateKeyStream >> strategy [ 
	^strategy
]
