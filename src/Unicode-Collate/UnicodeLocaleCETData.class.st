"
Instances of this class should hold Locale-specific alterations to the standard DUCET table.
The different locale modifications must be read from a suitable source, such as the CLDR base.

As the CLDR locale collate data format is a stateful list of modification to a root table, it is probably necessary with new classes (essentially a linked list with separate link classes representing level 1-4 differences) which is generated when parsing, and then converted into proper sequences to put in my instances. See http://unicode.org/reports/tr35/tr35-collation.html#Collation_Tailorings

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeLocaleCETData,
	#superclass : #Object,
	#instVars : [
		'collateTable'
	],
	#classVars : [
		'LocaleCETs'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'instance creation' }
UnicodeLocaleCETData class >> createNewFor: aLocale [
	^self new initializeFrom: (self loadCETDataFor: aLocale)
]

{ #category : #accessing }
UnicodeLocaleCETData class >> forLocale: aLocale [
	^LocaleCETs at: aLocale ifAbsentPut: [ self createNewFor: aLocale ]
]

{ #category : #'instance creation' }
UnicodeLocaleCETData class >> loadCETDataFor: aLocale [
	"Find and parse the CLDR collate alterations for aLocale"
	^self notYetImplemented
]

{ #category : #accessing }
UnicodeLocaleCETData >> collateEntryFor: aCharacter [
	aCharacter
		ifNil: [ ^ UnicodeDUCETData default collateEntryFor: aCharacter ].
	^ collateTable
		at: aCharacter codePoint
		ifAbsent: [ UnicodeDUCETData default collateEntryFor: aCharacter ]
]
