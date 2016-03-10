"
UnicodeSorter is an example implemention, meant to sorts strings according to a defined strategy.

The normal way to collate  would be by a Schwartzian transform; generating an association of CollateKeyStream -> string, sort these using methods in the CollateKeyStreams comparison category, then strio the CollateKeyStreams.
This will not require computation of full collate key arrays, but possibly recalculate the same collate sequence as a string is compared to multiple items.

This class instead sorts the input on the first collate key element of each string, then repeatedly re-sort by  subsequence collate key element the ranges that compared equal , until all ranges are sorted. 

TODO: Big-O comparison of worst-case  scenario for this approach vs the normal way (equally collating strings), and the importance  of using a search algorithm with good  performance in this case (O(n) vs O(n log n) for the viability of this case

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeSorter,
	#superclass : #Object,
	#instVars : [
		'strategy'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'instance creation' }
UnicodeSorter class >> forLocale: aLocale [
	^self strategy: (CollateStrategy forLocale: aLocale)
]

{ #category : #'instance creation' }
UnicodeSorter class >> new [
	^self strategy: CollateStrategy default
]

{ #category : #examples }
UnicodeSorter class >> sampleRandomWorkspace [
"The following is an example that compares using the sorter to a more traditional approach.
The traditional approach can be made faster by changing the CollateKeyStream buffer retention strategy."
|testStrings sorter testStringsSorted testStringsAssocs testStringsSorted2 testStringsAssocs3 testStringsSorted3|
testStrings := (1 to: 10000) collect: [ :i | WideString streamContents: [ :stream | 100 atRandom timesRepeat: [stream nextPut: 16r10FFFF atRandom asCharacter] ] ].

"Using sorter"
sorter := UnicodeSorter new.
testStringsSorted := sorter sort: testStrings copy.

"Classic approach"
testStringsAssocs := testStrings copy collect: [ :each | (CollateKeyStream on: each readStream unicodeCodePoints unicodeNFD) -> each ].

testStringsAssocs sort: [ :a :b | a key <= b key ].
testStringsSorted2 := testStringsAssocs collect: #value.


^testStringsSorted = testStringsSorted2
]

{ #category : #examples }
UnicodeSorter class >> sampleWorstCaseWorkspace [
"The following is an example of the worst case for the sort-per-collate-value approach; all Strings are equal, that is, we need to sort the full range string size times before concluding the ordering should stay as is"
|testString testStrings sorter testStringsSorted testStringsAssocs testStringsSorted2|
testString := WideString streamContents: [ :stream | 100 atRandom timesRepeat: [stream nextPut: 16r10FFFF atRandom asCharacter] ] .
testStrings := (1 to: 10000) collect: [ :i | testString].

"Using sorter"
sorter := UnicodeSorter new.
testStringsSorted := sorter sort: testStrings copy.

"Classic approach"
testStringsAssocs := testStrings copy collect: [ :each | (CollateKeyStream on: each readStream unicodeCodePoints unicodeNFD) -> each ].

testStringsAssocs sort: [ :a :b | a key <= b key ].
testStringsSorted2 := testStringsAssocs collect: #value.

^testStringsSorted = testStringsSorted2
]

{ #category : #'instance creation' }
UnicodeSorter class >> strategy: aCollateStrategy [
	^self basicNew initializeFor: aCollateStrategy
]

{ #category : #'initialize - release' }
UnicodeSorter >> initializeFor: aStrategy [
	strategy := aStrategy
]

{ #category : #'as yet unclassified' }
UnicodeSorter >> sort: aStringCollection [

	"Schwarz the collection"
	1 to: aStringCollection size do: [ :anIndex | |aString|
			aString := aStringCollection at: anIndex.
			aStringCollection at: anIndex put: (CollateKeyStream on: aString readStream unicodeCodePoints unicodeNFD strategy: strategy) -> aString ].
	self sort: aStringCollection from: 1 to: aStringCollection size.
	"Unscwartz"
	1 to: aStringCollection size do: [ :anIndex | |anAssoc|
			anAssoc := aStringCollection at: anIndex.
			aStringCollection at: anIndex put: anAssoc value ].
		^aStringCollection
]

{ #category : #'private - sort' }
UnicodeSorter >> sort: collateStreamsAndStrings from: start to: end [
	| rangeStart element |
	collateStreamsAndStrings mergeSortFrom: start to: end by: [ :a :b | a key peek isNil or: [b key peek notNil and: [a key peek <= b key peek]] ].
	rangeStart := start.
	element := (collateStreamsAndStrings at: rangeStart) key next.
	element ifNil: ["If first element is nil, we've checked range to end of streams, and the whole range is equal.
		"^nil ].
	start + 1 to: end do:
		[ :i | 
		(element ~= (element := (collateStreamsAndStrings at: i) key next))
			ifTrue:
				[ | rangeEnd |
				rangeEnd := i - 1.
				rangeEnd - rangeStart > 0
					ifTrue: [ self sort: collateStreamsAndStrings from: rangeStart to: rangeEnd.].
				rangeStart := i  ] ].
	end - rangeStart > 0
					ifTrue: [ self sort: collateStreamsAndStrings from: rangeStart to: end]
]
