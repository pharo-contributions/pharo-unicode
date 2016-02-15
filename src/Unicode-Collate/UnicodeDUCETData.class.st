"
This class holds the collate element data in the DUCET table (http://www.unicode.org/Public/UCA/latest/allkeys.txt). 
It also  creates derived collation elements when needed, see  http://unicode.org/reports/tr10/#S2.2

The table holds both CollateSequences, and CollateEntries, when loopups are fully resolved it is thus important to call #value in order to get the actual sequence in all cases.

Users should normally not consult the DUCET table data directly, but rather use a CollateStrategy, where one  can  both specify collate properties not contained in the collate element data, as well as potentially using different datatables  tailored for specific locales. 


"
Class {
	#name : #UnicodeDUCETData,
	#superclass : #Object,
	#instVars : [
		'collateTable'
	],
	#classVars : [
		'DUCET',
		'EmptyElement'
	],
	#category : #'Unicode-Collate'
}

{ #category : #'private - import' }
UnicodeDUCETData class >> addCEFrom: allKeysStream to: collateTable [
	|  codePoints element newSequence |
	"<entry>       := <charList> ';' <collElement>+ <eol>
	<collElement> := '[' <alt> <char> '.' <char> '.' <char> ('.' <char>)* ']'
	<alt>         := '*' | '.'"
	codePoints := OrderedCollection new.
	[allKeysStream peekFor: $;] 
		whileFalse: [ codePoints add: (Number readFrom: allKeysStream base: 16).
	"Skip next char if space"
	(allKeysStream peekFor: Character space)].
	(allKeysStream peekFor: Character space) ifFalse: [ self error: 'Strange format'].

	newSequence := self sequenceFrom: allKeysStream.
	element := collateTable.
	"Find the correct entry to add new sequence to."
	codePoints
		do:
			[ :codePoint | 
			element := element
				followedBy: codePoint
				ifAbsentPut: [ CollateEntry new ] ].
	element setSequence: newSequence.
	^ element
]

{ #category : #accessing }
UnicodeDUCETData class >> default [
	^DUCET ifNil: [self importDUCET ]
]

{ #category : #accessing }
UnicodeDUCETData class >> forLocale: aLocale [
	aLocale ifNil: [^self default].
	^UnicodeLocaleCETData forLocale: aLocale
]

{ #category : #'private - import' }
UnicodeDUCETData class >> importDUCET [
	"http://unicode.org/reports/tr10/#File_Format
	<collationElementTable> := <version> 
                           <variable>?
                           <backwards>*
                           <entry>+
	@<version> := <major>.<minor>.<variant> <eol>
	<variable>       := '@variable ' <variableChoice> <eol>
	<variableChoice> := 'blanked' | 'non-ignorable' | 'shifted'
	<backwards> := ('@backwards ' | '@forwards ') <levelNumber> <eol>"

	| allKeysStream collateTable |
	allKeysStream := (ZnClient new
		streaming: true;
		get: 'http://www.unicode.org/Public/UCA/latest/allkeys.txt') ascii.
	"Skip properties preceding entries"
	[ '#@' includes: allKeysStream peek ]
		whileTrue: [ allKeysStream upTo: Character lf ].
	allKeysStream next.
	collateTable := CollateEntry new.
	[ allKeysStream atEnd ]
		whileFalse: [ self addCEFrom: allKeysStream to: collateTable ].
	collateTable minimize.
	^ DUCET := self new initializeFrom: collateTable
]

{ #category : #'class initialization' }
UnicodeDUCETData class >> initialize [
	EmptyElement := CollateSequence fromElements: #((0 0 0 false))
]

{ #category : #'private - import' }
UnicodeDUCETData class >> sequenceFrom: aCEStream [
	"String on format '[*0032.0000.0000][.0000.0020.0000]'"
	| collateElements  |
	collateElements := OrderedCollection new.
	[aCEStream peekFor: $[] whileTrue: 
		[| weight level1 level2 level3| 
		weight := aCEStream next = $*.
		level1 := Number readFrom: (aCEStream next: 4) base: 16.
		aCEStream next = $. ifFalse: [ self error: 'Invalid file' ].
		level2 := Number readFrom: (aCEStream next: 4) base: 16.
		aCEStream next = $. ifFalse: [ self error: 'Invalid file' ].
		level3 := Number readFrom: (aCEStream next: 4) base: 16.
		aCEStream next = $] ifFalse: [ self error: 'Invalid file' ].
		collateElements add: { level1. level2. level3. weight }].
	"Skip to next line"
	aCEStream upTo: Character lf.
	^CollateSequence fromElements:  collateElements.

]

{ #category : #accessing }
UnicodeDUCETData >> collateEntryFor: aCodePoint [
	aCodePoint ifNil: [ ^ EmptyElement ].
	^ collateTable
		followedBy: aCodePoint
		ifAbsent: [ (self hangulCollateSequenceFor: aCodePoint) ifNil: [self implicitlyWeighedCollateSequenceFor: aCodePoint ]]
]

{ #category : #accessing }
UnicodeDUCETData >> hangulCollateSequenceFor: aCodePoint [
	"Should create a collate sequence for hangul codepoints, see http://unicode.org/reports/tr10/#Hangul_Collation"

	^ (UnicodeCharacterData isHangulSyllableCodePoint: aCodePoint)
		ifTrue: [ self notYetImplemented ]
]

{ #category : #'private - implicit weighing' }
UnicodeDUCETData >> implicitWeightBaseFor: aCodePoint [
	"Implicit weight base value: http://unicode.org/reports/tr10/#Implicit_Weights , table 16"

	"Basic block"
	(((16r4E00 to: 16r9FFF) includes: aCodePoint) or: 
	"Compatability Ideographs"
	[(16rF900 to: 16rFAFF) includes: aCodePoint ]) ifTrue: [^16rFB40 ].
	"Not ALL of the codepoints in these blocks have the property Unified Ideograph, but use this for now, later on we can import from Unihan.zip to fix all cases if needed"
	"CJK extension A"
	(((16r3400 to: 16r4DBF) includes: aCodePoint) or: 
	["CJK extension B"
	((16r20000 to: 16r2A6DF) includes: aCodePoint) or: 
	["CJK extension C"
	((16r2A700 to: 16r2B73F) includes: aCodePoint) or: 
	["CJK extension D"
	((16r2B740 to: 16r2B81F) includes: aCodePoint) or: 
	["CJK extension D"
	(16r2B820 to: 16r2CEAF) includes: aCodePoint]]]]) ifTrue: [^16rFB80].
	"Anything else"
	^16rFBC0
]

{ #category : #accessing }
UnicodeDUCETData >> implicitlyWeighedCollateSequenceFor: aCodePoint [
	"Should create an implicitly weighed collate sequences, see http://unicode.org/reports/tr10/#S2.2"
	| base aaaa bbbb |
		
	base := self implicitWeightBaseFor: aCodePoint.
	aaaa := aCodePoint >> 15 + base.
	bbbb := (aCodePoint bitAnd: 16r7FFF) bitOr: 16r8000.
	
^CollateSequence fromElements: { { aaaa. 16r20. 16r2. false}. { bbbb. 0. 0. false }.  }
]

{ #category : #'initialize - release' }
UnicodeDUCETData >> initializeFrom: aCollateTable [
	collateTable := aCollateTable
]
