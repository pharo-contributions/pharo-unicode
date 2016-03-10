"
This class holds the collate element data in the DUCET table (http://www.unicode.org/Public/UCA/latest/allkeys.txt). 
It also  creates derived collation elements when needed, see  http://unicode.org/reports/tr10/#S2.2

The table holds both CollateSequences, and CollateEntries, when loopups are fully resolved it is thus important to call #value in order to get the actual sequence in all cases.

Users should normally not consult the DUCET table data directly, but rather use a CollateStrategy, where one  can  both specify collate properties not contained in the collate element data, as well as potentially using different datatables  tailored for specific locales. 

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).

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

{ #category : #'private - import' }
UnicodeDUCETData class >> addTibetanContractionsTo: collateTable [ 
	"http://unicode.org/reports/tr35/tr35-collation.html#tibetan_contractions"
	"This is needed so for instance 
	0FBC 0062
	0FB2 0F71 0001 0F80 0061
	0FB2 0001 0F80 0061
	sorts properly when our use of the CollateEntry datastructure relies on there being no holes 
	(and it does, we have no way of reverting a composed entry back to its constituent parts)"
	|data codePointSequences collateSequences |
		
	[ |FB2 FB3 F71 F71F72 F71F74|
	FB2 := (collateTable followedBy: 16r0FB2) value.
	FB3 := (collateTable followedBy: 16r0FB3) value.
	F71 := (collateTable followedBy: 16r0F71) value.
	F71F72 := ((collateTable followedBy: 16r0F71) followedBy: 16r0F72) value.
	F71F74 := ((collateTable followedBy: 16r0F71) followedBy: 16r0F74) value.
	data := {
		"These are actually missing"
		#(16rFB2 16r0F71) -> (FB2, F71).
		#(16rFB3 16r0F71) -> (FB3, F71).
		"These are needed to preserve sort order, after missing sequences are added"
		#(16rFB2 16r0F71 16r0F72)	-> 	(FB2, F71F72).
		#(16rFB2 16r0F73) 				-> (FB2, F71F72).
		#(16rFB2 16r0F71 16r0F74)	-> (FB2, F71F74).
		#(16rFB2 16r0F75)				-> (FB2, F71F74).
		
		#(16rFB3 16r0F71 16r0F72)	-> 	(FB2, F71F72).
		#(16rFB3 16r0F73) 				-> (FB2, F71F72).
		#(16rFB3 16r0F71 16r0F74)	-> (FB3, F71F74).
		#(16rFB3 16r0F75)				-> (FB3, F71F74).}] value. 
	codePointSequences := data collect: #key.
	collateSequences := data collect: #value.
	codePointSequences doWithIndex: [ :codePoints :seqIx| | element |
	element := collateTable.
	"Find the correct entry to add new sequence to."
	codePoints
		do:
			[ :codePoint | 
			element := element
				followedBy: codePoint
				ifAbsentPut: [ CollateEntry new ] ].
			element value ifNil: [ element setSequence: (collateSequences at: seqIx)]].
	
]

{ #category : #'private - import' }
UnicodeDUCETData class >> checkWellFormedness: aTable [
	"We need a well-formed table where no sequence is nil, or we may get stuck in a rut"
	aTable isWellFormed ifFalse: [ self addTibetanContractionsTo: aTable ].
	^aTable isWellFormed
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
UnicodeDUCETData class >> import: anAllKeysStream [
	"Import a table from the stream, 
	where source is on the format specified in 	http://unicode.org/reports/tr10/#File_Format
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
	collateTable := CollateEntry new setSequence: EmptyElement.
	[ allKeysStream atEnd ]
		whileFalse: [ self addCEFrom: allKeysStream to: collateTable ].
	(self checkWellFormedness: collateTable) 
		ifFalse: [^self error: 'CollateTable is no longer well formed after our adjustments, fix, or fall back to using an older Unicode version'].
	^collateTable minimize.
]

{ #category : #'private - import' }
UnicodeDUCETData class >> importDUCET [
	"Import the DUCET data for latest Unicode version"

	| collateTable |
	collateTable := self
		import:
			(ZnClient new
				streaming: true;
				get: 'http://www.unicode.org/Public/UCA/latest/allkeys.txt')
				ascii.
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
	aCodePoint ifNil: [ ^ collateTable ].
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
	"Codepoints in CJK ranges have different weight from the rest"
	UnicodeCharacterData specialRanges do: 
		[:specialRange | (specialRange first codePoint <= aCodePoint and: 
							[ specialRange last codePoint >= aCodePoint and: 
							[specialRange first name beginsWith: '<CJK Ideograph' ]]) 
								ifTrue: ["Only base set has $, after stem, rest are extension sets"
								^(specialRange first name at: 15) = $, 
									ifTrue: [ 16rFB40  ] 
									ifFalse: [16rFB80 ] ]].
	"Everything else"
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
