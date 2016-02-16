"
A variable weighing is a stateless, systematic modification to collate elements.

http://unicode.org/reports/tr10/#Variable_Weighting

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
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
