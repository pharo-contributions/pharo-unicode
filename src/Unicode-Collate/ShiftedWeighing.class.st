"
Variable collation elements are reset to zero at levels one through three. In addition, a new fourth-level weight is appended, whose value depends on the type, as shown in Table 11. Any subsequent primary or secondary ignorables following a variable are reset so that their weights at levels one through four are zero.

Table 11. L4 Weights for Shifted Variables:
Type								L4		Examples
L1, L2, L3 = 0							0000	null [.0000.0000.0000.0000]
L1 ≠ 0, Variable						old L1	space [.0000.0000.0000.0209]
L1=0, L3 ≠ 0, following a Variable		0000	combining grave [.0000.0000.0000.0000]
L1 = 0, L3 ≠ 0, not following a Variable	FFFF	combining grave [.0000.0035.0002.FFFF]
L1 ≠ 0, not Variable					FFFF	Capital A [.06D9.0020.0008.FFFF]
						
Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #ShiftedWeighing,
	#superclass : #VariableWeight,
	#category : #'Unicode-Collate'
}

{ #category : #accessing }
ShiftedWeighing class >> addLevel: aLevel in: aSequence precededBy: precedingSequence to: aBuffer [
	"Add all entries in aSequence at aLevel to aStream, respecting my weighting.
	Return the amount of entries added"
	|total prev keyDecider prevIx prevVariable |
	prev := precedingSequence value.
	prevIx := prev ifNotNil: [ prev size].
	total := 0.
	prevVariable := [:curr :currIx | prev notNil and: 
		[(prev variablyWeighedAt: prevIx) and: 
			[ (curr at: currIx level: 1) = 0 or: 
			[(curr at: currIx level: 2) = 0]]]].
	keyDecider := aLevel = 4 
		ifTrue: [[:curr :currIx | 
			(curr variablyWeighedAt: currIx) 
				ifTrue: [ curr at: currIx level: 1] 
				ifFalse: [
					((curr at: currIx level: 1) = 0 and: 
					[(curr at: currIx level: 2) = 0 and: 
					[(curr at: currIx level: 3) = 0 ]])
						ifFalse: [self terminalWeight]
						ifTrue: [0]]]]
		ifFalse: [[:curr :currIx | 
			(curr variablyWeighedAt: currIx) 
				ifTrue: [0] 
				ifFalse: [curr at: currIx level: aLevel]] ]  .
	1 to: aSequence value size do: [: i | |key|
		key := (prevVariable value: aSequence value value: i)
			ifTrue: [0]
			ifFalse: [keyDecider value: aSequence value value: i ]. 
		key > 0 ifTrue: [aBuffer add: key.
			 total := total + 1].
		prev := aSequence value.
		prevIx := i ] .
	^total
]

{ #category : #constants }
ShiftedWeighing class >> levels [
	^4
]

{ #category : #constants }
ShiftedWeighing class >> terminalWeight [
	"This value must be larger than any L1 value in DUCET.
	As per the description in TR, we chose 16rFFFF"
		^16rFFFF
]
