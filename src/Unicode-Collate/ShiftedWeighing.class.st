"
Variable collation elements are reset to zero at levels one through three. In addition, a new fourth-level weight is appended, whose value depends on the type, as shown in Table 11. Any subsequent primary or secondary ignorables following a variable are reset so that their weights at levels one through four are zero.

Table 11. L4 Weights for Shifted Variables:
Type								L4		Examples
L1, L2, L3 = 0							0000	null [.0000.0000.0000.0000]
L1 ≠ 0, Variable						old L1	space [.0000.0000.0000.0209]
L1=0, L3 ≠ 0, following a Variable		0000	combining grave [.0000.0000.0000.0000]
L1 = 0, L3 ≠ 0, not following a Variable	FFFF	combining grave [.0000.0035.0002.FFFF]
L1 ≠ 0, not Variable					FFFF	Capital A [.06D9.0020.0008.FFFF]
"
Class {
	#name : #ShiftedWeighing,
	#superclass : #VariableWeight,
	#category : #'Unicode-Collate'
}

{ #category : #constants }
ShiftedWeighing class >> levels [
	^4
]
