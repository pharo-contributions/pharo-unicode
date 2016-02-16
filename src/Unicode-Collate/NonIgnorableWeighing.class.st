"
Variable collation elements are not reset to be quaternary collation elements. All mappings defined in the table are unchanged.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #NonIgnorableWeighing,
	#superclass : #VariableWeight,
	#category : #'Unicode-Collate'
}

{ #category : #accessing }
NonIgnorableWeighing class >> addLevel: aLevel in: aSequence precededBy: precedingSequence to: aBuffer [
	"Return the amount of entries added"
	"Add all key elements to aBuffer, precedingBuffer unused"
	|total|
	total := 0.
	1 to: aSequence value size do: [:i | |key|
		key := aSequence value at: i level: aLevel.
		key > 0 ifTrue: [aBuffer add: key.
			 total := total + 1]].
	^total
]

{ #category : #constants }
NonIgnorableWeighing class >> levels [
	^3
]
