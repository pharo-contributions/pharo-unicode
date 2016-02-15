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
	"Read the next collate element at the current level from nkdStream into buffer"

	| entry candidates ccCheck isCC match |
	ccCheck := [ :codePoint | (UnicodeCharacterData forCodePoint: codePoint ifAbsent: nil) ifNotNil: [ :data | data ccc > 0 ] ifNil: [ false ] ].
	nfdStream next
		ifNil: [ 
			level < strategy weight levels
				ifTrue: [buffer add: 0.
					level := level + 1.
					nfdStream reset.
					"Quick hack; start off using the empty element when we've switched levels"
					entry := strategy collateEntryFor: nil ]
				ifFalse: [^buffer add: nil; add: nil ] ]
		ifNotNil: [ :codePoint | entry := strategy collateEntryFor: codePoint ].	"Reached end of level"
	"Resolve combined entries. A combination is either a sequence of starters, or a sequence of starters ending in combining marks. Combining marks are special; the first one that has a combination will be used. See http://unicode.org/reports/tr10/#S2.1 "
	
	[	candidates := OrderedCollection with: nfdStream peek.
		isCC := ccCheck value: candidates last.
		[ isCC ] whileTrue:
			[ | candidate |
			candidate := nfdStream
				next;
				peek.
			isCC := ccCheck value: candidate.
			isCC
				ifTrue: [ candidates add: candidate ] ].
		match := candidates detect: [ :one | ((entry followedBy: one) ifNotNil: [ :e | entry := e ]) notNil] ifNone: nil.
		match ifNotNil: [ candidates remove: match ].
		match notNil ] whileTrue.
	"Remove non-combining starter from candidates that need to "
	(ccCheck value: candidates last) ifFalse: [ candidates removeLast ].
	"addLevel:in:precededBy:to: returns the number of values added to buffer.
	(Collate entries with value 0 are not part of key). If no values are actually added, call fillBuffer again."
	"TODO: Check that no weigings does alterations on the boundaries we fill buffer, so nil can be used safely for first element "
	(candidates
		inject: (strategy weight addLevel: level in: entry precededBy: nil to: buffer)
		into: [ :sub :next | sub + (strategy weight addLevel: level in: (entry :=  strategy collateEntryFor: next) precededBy: entry to: buffer) ]) = 0
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
