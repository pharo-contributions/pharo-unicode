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

{ #category : #'instance creation' }
UnicodeSorter class >> strategy: aCollateStrategy [
	^self basicNew initializeFor: aCollateStrategy
]

{ #category : #'initialize - release' }
UnicodeSorter >> initialize: aStrategy [
	strategy := aStrategy
]

{ #category : #'as yet unclassified' }
UnicodeSorter >> sort: aStringCollection [
	| collateStreams |
	collateStreams := aStringCollection collect: [ :aString | CollateKeyStream on: aString collateTable: strategy collateTable ].
	self sort: collateStreams from: 1 to: collateStreams size.
	^collateStreams collect: #contents
]

{ #category : #'private - sort' }
UnicodeSorter >> sort: collateStreams from: start to: end [
	| rangeStart element |
	collateStreams mergeSortFrom: start to: end by: [ :a :b | a peek < b peek ].
	rangeStart := start.
	element := (collateStreams at: rangeStart) next.
	start + 1 to: end do:
		[ :i | 
		element != (element := (collateStreams at: i) next)
			ifTrue:
				[ | rangeEnd |
				rangeEnd := i - 1.
				rangeEnd - rangeStart > 1
					ifTrue: [ self sort: collateStreams from: rangeStart to: rangeEnd.
						rangeStart := i ] ] ]
]
