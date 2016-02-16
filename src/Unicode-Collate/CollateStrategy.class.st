"
A CollateStrategy defines the user-customizable parameters for how strings should be sorted.

At the moment, this includes:  

- The collate table to use
- Variable weight setting  http://unicode.org/reports/tr10/#Variable_Weighting
"
Class {
	#name : #CollateStrategy,
	#superclass : #Object,
	#instVars : [
		'cetData',
		'variableWeight'
	],
	#classVars : [
		'Default'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'instance creation' }
CollateStrategy class >> collateTable: aCollateTable [
	"Use a strategy for collating that respects the given collate table"
	^self new collateTable: aCollateTable
]

{ #category : #defaults }
CollateStrategy class >> default [
	^Default ifNil: [ Default :=  self collateTable: UnicodeDUCETData default ]
]

{ #category : #'instance creation' }
CollateStrategy class >> forLocale: aLocale [
	^self collateTable: (UnicodeDUCETData forLocale: aLocale)
]

{ #category : #weighing }
CollateStrategy >> blanked [
	variableWeight := BlankedWeighing
]

{ #category : #collating }
CollateStrategy >> collate: aCollateStream to: anotherCollateStream [
	"A very basic collate strategy"
	^(aCollateStream peek ) <= (anotherCollateStream peek )
]

{ #category : #collating }
CollateStrategy >> collate: aCollateStream to: anotherCollateStream at: aCollateLevel [
	"A very basic collate strategy"
	^(aCollateStream peek level: aCollateLevel) <= (anotherCollateStream peek level: aCollateLevel)
]

{ #category : #accessing }
CollateStrategy >> collateEntryFor: aCodePoint [
	^cetData collateEntryFor: aCodePoint
]

{ #category : #accessing }
CollateStrategy >> collateTable [
	^cetData
]

{ #category : #'initialize - release' }
CollateStrategy >> collateTable: aCollateTable [
	cetData := aCollateTable
]

{ #category : #'private  - sort delegation' }
CollateStrategy >> collectRanges: aCollateStreamCollection oldRanges: startRanges at: aLevel [
	"Put this here, rather than in sorter, as I am uncertain whether collate strategies exist where ranges will have to be defined differently. 
	For now; the ranges are the elements after a sort that have the same collate value at the current level"
	|newRanges|
	newRanges := startRanges class new: startRanges size.
	startRanges do: [ :range | |rangeStart lastVal|
			rangeStart := range first.
			lastVal := (aCollateStreamCollection at: range first) peek level: aLevel.
			range first + 1 to: range last do: [:i | lastVal ~= (lastVal := (aCollateStreamCollection at: i) peek level: aLevel) ifTrue: [rangeStart - i > 0 ifTrue: [newRanges add: (rangeStart to: i)].
					rangeStart := i ]]].
		^newRanges
]

{ #category : #'initialize - release' }
CollateStrategy >> initialize [
	variableWeight := NonIgnorableWeighing.
]

{ #category : #weighing }
CollateStrategy >> nonIgnorable [
	variableWeight := NonIgnorableWeighing
]

{ #category : #weighing }
CollateStrategy >> shiftTrimmed [
	variableWeight := ShiftTrimmedWeighing
]

{ #category : #weighing }
CollateStrategy >> shifted [
	variableWeight := ShiftedWeighing
]

{ #category : #accessing }
CollateStrategy >> weight [
	^variableWeight
]
