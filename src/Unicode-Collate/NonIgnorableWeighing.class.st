"
Variable collation elements are not reset to be quaternary collation elements. All mappings defined in the table are unchanged.
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
