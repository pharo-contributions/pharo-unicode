"
Variable collation elements and any subsequent ignorable collation elements are reset so that all weights (except for the identical level) are zero. It is the same as the Shifted Option, except that there is no fourth level.
"
Class {
	#name : #BlankedWeighing,
	#superclass : #ShiftedWeighing,
	#category : #'Unicode-Collate'
}

{ #category : #constants }
BlankedWeighing class >> levels [
	^3 
]
