"
A variable weighing is a stateless, systematic modification to collate elements.

http://unicode.org/reports/tr10/#Variable_Weighting

"
Class {
	#name : #VariableWeight,
	#superclass : #Object,
	#category : #'Unicode-Collate'
}

{ #category : #accessing }
VariableWeight class >> addLevel: aLevel in: aSequence precededBy: precedingSequence to: aStream [
	"Add all entries in aSequence at aLevel to aStream, respecting my weighting.
	Return the amount of entries added"
	^self subclassResponsibility
]

{ #category : #constants }
VariableWeight class >> levels [
	"How many levels does a collate element support using this variable weight scheme?"
	^self subclassResponsibility
]
