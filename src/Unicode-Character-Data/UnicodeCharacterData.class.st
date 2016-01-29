"
I am UnicodeCharacterData, I represent one record in the Unicode Character Database and describe properties of one character.

I am uniquely identified by my code point (#codePoint), my Unicode scalar value.

I have an official name (#name). Sometimes I also know my older name (#oldName).

I have a general and a bidirectional category (#generalCategory  #bidirectionalCategory) and I know my canonicalCombiningClasses (#canonicalCombiningClasses).

If applicable, I know my case mapping, what code point is like me, but upper, lower or title cased (#uppercase  #lowercase #titelcase)

If applicable, I know my numerical mapping, the mathematical number that I represent (#decimalDigitValue #digitValue #numericValue).

If I am a precomposed character, I know my decomposition (#decompositionMapping). This information is needed for normalization.

I also known whether I am mirrored (#mirrored).

My class side holds the full database of all official Unicode characters, indexed by codePoint (#database), which is loaded lazily from the official URL or from a local file system cache.

Given a Unicode code point, my class method #forCodePoint: will answer an instance of me. A NotFound exception is raised if the code point is outside the allowed range.

Given an integer, #unicodeCharacterData will answer an instance of me.

	16r00C5 unicodeCharacterData.

The character that I represent is available with #character.  Given a character instance, #unicodeCharacterData will answer an instance of me.

	$a unicodeCharacterData.
	$é unicodeCharacterData.
	$7 unicodeCharacterData.

More:

For the interpretation of these concepts, please consult the Unicode documentation at http://unicode.org

In particular, the UCD dataset is described in detail in http://www.unicode.org/reports/tr44/ and available directly at http://www.unicode.org/Public/UNIDATA/ and can be downloaded as http://www.unicode.org/Public/UNIDATA/UCD.zip.

Implementation notes

To conserve space (the full database has about 30K entries), some of my fields (canonicalCombiningClass, generalCategory, bidirectionalCategory and mirrored) are combined in bitEncodedFields.

Furthermore, since many entries (about 20K) have neither decomposition, case or numeric mappings, I have no instance variables for these properties, but my extended subclass does.


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeCharacterData,
	#superclass : #Object,
	#instVars : [
		'codePoint',
		'name',
		'bitEncodedFields'
	],
	#classVars : [
		'CompositionExclusions',
		'HangulCache',
		'JamoShortNames',
		'NormalizationQuickCheck',
		'SpecialRanges',
		'UnicodeCharacterDatabase'
	],
	#category : #'Unicode-Character-Data'
}

{ #category : #constants }
UnicodeCharacterData class >> bidirectionalCategories [
	"Return the possible values for bidirectional category"
	
	"Table 13. Bidi_Class Values in http://www.unicode.org/reports/tr44/#Bidi_Class_Values"
	
	^ #(L R AL EN ES ET AN CS NSM BN B S WS ON LRE LRO RLE RLO PDF LRI RLI FSI PDI)
]

{ #category : #initialization }
UnicodeCharacterData class >> cleanUp: aggressive [
	"self cleanUp"
	"self cleanUp: true"

	self resetHangulDatabase.
	"Not 100% sure this is a good idea"
	aggressive
		ifTrue: [ self resetDataSets ]
]

{ #category : #'accessing - datasets' }
UnicodeCharacterData class >> compositionExclusions [
	"D112"
	
	^ CompositionExclusions ifNil: [ CompositionExclusions := self loadCompositionExclusions ]
]

{ #category : #'private - composition exclusion' }
UnicodeCharacterData class >> compositionExclusionsFile [
	^ 'CompositionExclusions.txt'
]

{ #category : #'accessing - datasets' }
UnicodeCharacterData class >> database [
	"Return the Unicode Character Database an a dictionary mapping each codepoint to an instance of me. 
	Load the database if needed from the official URL over the internet or from a local filesystem cache."
	
	UnicodeCharacterDatabase ifNil: [ self initializeDatabase ].
	^ UnicodeCharacterDatabase
]

{ #category : #constants }
UnicodeCharacterData class >> decompositionCompatibilityTypes [
	"Return the possible values for type of compatibility decomposition"
	
	"Table 14. Compatibility Formatting Tags in http://www.unicode.org/reports/tr44/#Character_Decomposition_Mappings"
	
	^ #(font noBreak initial medial final isolated circle super sub vertical wide narrow small square fraction compat)
]

{ #category : #'private - derived normalization properties' }
UnicodeCharacterData class >> derivedNormalizationPropertiesFile [
	^ 'DerivedNormalizationProps.txt'
]

{ #category : #'private - database' }
UnicodeCharacterData class >> extractSpecialRanges: collectionOfCharacterData [
	|ranges|
	ranges := (collectionOfCharacterData 
			select: [ :each | (each name endsWith: 'First>') or: [ each name endsWith: 'Last>' ] ])
				pairsCollect: [ :first :last | Array with: first with: last ].
	"Happily, in Pharo, removeAllSuchThat does *not* return the collection of removed elements..."
	collectionOfCharacterData 
			removeAllSuchThat: [ :each | (each name endsWith: 'First>') or: [ each name endsWith: 'Last>' ] ].
	^ranges
]

{ #category : #accessing }
UnicodeCharacterData class >> forCodePoint: integer [
	"Return an instance of me for codepoint integer. Fail if there is no such codepoint."

	^ self
		forCodePoint: integer
		ifAbsent: [ KeyNotFound signalFor: integer in: self database ]
]

{ #category : #accessing }
UnicodeCharacterData class >> forCodePoint: integer ifAbsent: block [
	"Return an instance of me for codepoint integer. Execute block if there is no such codepoint."
	
	^ self database 
		at: integer 
		ifAbsent: [ self hangulDataForCodePoint: integer ifAbsent: block ]
]

{ #category : #constants }
UnicodeCharacterData class >> generalCategories [
	"Return the possible values for general category"
	
	"See Table 12. General_Category Values in http://www.unicode.org/reports/tr44/#General_Category_Values"
	
	^ #(Lu Ll Lt Lm Lo Mn Mc Me Nd Nl No Pc Pd Ps Pe Pi Pf Po Sm Sc Sk So Zs Zl Zp Cc Cf Cs Co Sn)
]

{ #category : #'private - database common' }
UnicodeCharacterData class >> getUnicodeCharacterDatabaseRaw: file [
	"Return the contents of file from the Unicode Character Database specification as a String.
	Optionally use a locally downloaded cache, to enable this,
	decompress http://www.unicode.org/Public/UNIDATA/UCD.zip next to your image."
	
	| fileReference url |
	fileReference := self unicodeCharacterDatabaseCacheDirectory / file.
	url := self unicodeCharacterDatabaseBaseUrl / file.
	^ fileReference exists
		ifTrue: [ 
			fileReference binaryReadStreamDo: [ :bin |
				(ZnCharacterReadStream on: bin) upToEnd ] ]
		ifFalse: [ 
			url retrieveContents ]
]

{ #category : #'private - hangul' }
UnicodeCharacterData class >> hangulDataForCodePoint: integer [
	^ self 
		hangulDataForCodePoint: integer 
		ifAbsent: [ KeyNotFound signalFor: integer in: self database ]
]

{ #category : #'private - hangul' }
UnicodeCharacterData class >> hangulDataForCodePoint: integer ifAbsent: aBlock [
	"Could use on: DomainError do: aBlock rather than check range here explicitly, not sure of the perf overhead though"

	(integer notNil and: [ self isHangulSyllableCodePoint: integer ])
		ifFalse: [ ^ aBlock value ].
	^ self hangulDatabase 
		at: integer 
		ifAbsentPut: [ 
			UnicodeCharacterDataExtended new 
				initializeFromHangulSyllable: integer;
				yourself ]
]

{ #category : #'private - hangul' }
UnicodeCharacterData class >> hangulDatabase [
	"Thumb-in-air figure; assume 1000 hangul characters will be a good working set."

	^ HangulCache
		ifNil: [ 
			HangulCache := LRUCache new
				maximumWeight: 1000;
				yourself ]
]

{ #category : #initialization }
UnicodeCharacterData class >> initializeDatabase [
	| entries |
	entries := self loadUnicodeCharacterDatabase.
	SpecialRanges := self extractSpecialRanges: entries.
	UnicodeCharacterDatabase := IdentityDictionary new: entries size.
	entries do: [ :each | 
		UnicodeCharacterDatabase at: each codePoint put: each ]
]

{ #category : #initialization }
UnicodeCharacterData class >> initializeJamoShortNames [
	JamoShortNames := self loadJamoShortNames 
]

{ #category : #'private - hangul' }
UnicodeCharacterData class >> isHangulSyllableCodePoint: codePoint [
	^ codePoint between: 16rAC00 and: 16rD7A3
]

{ #category : #'accessing - normalization quick check' }
UnicodeCharacterData class >> isSupplementaryCodePoint: codePoint [
	^ codePoint between: 16r10000 and: 16r10FFFF
]

{ #category : #'accessing - datasets' }
UnicodeCharacterData class >> jamoShortNames [
	JamoShortNames ifNil: [ self initializeJamoShortNames  ].
	^JamoShortNames
]

{ #category : #'private - jamo short names' }
UnicodeCharacterData class >> jamoShortNamesFile [
	^ 'Jamo.txt'
]

{ #category : #'private - composition exclusion' }
UnicodeCharacterData class >> loadCompositionExclusions [
	| compositionExclusions |
	compositionExclusions := IdentitySet new.
	(self getUnicodeCharacterDatabaseRaw: self compositionExclusionsFile) linesDo: [ :each | 
		(each notEmpty and: [ each first ~= $# ])
			ifTrue: [ compositionExclusions add: (Integer readFrom: each base: 16) ] ].
	^ compositionExclusions
]

{ #category : #'private - derived normalization properties' }
UnicodeCharacterData class >> loadDerivedNormalizationProperties [
	^ OrderedCollection streamContents: [ :out |
		(self getUnicodeCharacterDatabaseRaw: self derivedNormalizationPropertiesFile) linesDo: [ :line |
			(line isEmpty or: [ line first = $# ])
				ifFalse: [ 
					out nextPut: (self parseDerivedNormalizationProperty: line) ] ] ]
]

{ #category : #'private - jamo short names' }
UnicodeCharacterData class >> loadJamoShortNames [
	| shortNames |
	shortNames := IdentityDictionary new.
	(self getUnicodeCharacterDatabaseRaw: self jamoShortNamesFile)
		linesDo: [ :each | 
			(self parseUnicodeJamoShortNames: each) 
				ifNotNil: [ :shortName | shortNames add: shortName ] ].
	^ shortNames
]

{ #category : #'private - derived normalization properties' }
UnicodeCharacterData class >> loadNormalizationQuickCheck [
	| normalizationQuickCheck derivedNormalizationProperties values |
	normalizationQuickCheck := IdentityDictionary new.
	derivedNormalizationProperties := self loadDerivedNormalizationProperties.
	#(NFC_QC NFD_QC NFKC_QC NFKD_QC) do: [ :property |
		values := IdentityDictionary new.
		derivedNormalizationProperties 
			select: [ :each | (each at: #property) = property ] 
			thenDo: [ :each | 
				(each at: #range) isInteger
					ifTrue: [ 
						values at: (each at: #range) put: (each at: #value) asSymbol ] 
					ifFalse: [ 
						(each at: #range) do: [ :codePoint | 
							values at: codePoint put: (each at: #value) asSymbol ] ] ].
		normalizationQuickCheck at: property put: values ].
	^ normalizationQuickCheck
]

{ #category : #'private - database' }
UnicodeCharacterData class >> loadUnicodeCharacterDatabase [
	^ OrderedCollection streamContents: [ :out |
		(self getUnicodeCharacterDatabaseRaw: self unicodeCharacterDatabaseFile) linesDo: [ :each |
			out nextPut: (self parseUnicodeCharacterData: each) ] ]
]

{ #category : #queries }
UnicodeCharacterData class >> minimalCCC [	
	| ccc |
	ccc := IdentityDictionary new.
	(self database values reject: #isStarter)
		do: [ :each | ccc at: each codePoint put: each ccc ].
	^ ccc
]

{ #category : #queries }
UnicodeCharacterData class >> minimalDecomposition [
	| decomposition |
	decomposition := IdentityDictionary new.
	(self database values select: #hasDecomposition)
		do: [ :each | decomposition at: each codePoint put: each decompositionMapping ].
	^ decomposition
]

{ #category : #queries }
UnicodeCharacterData class >> nameMatching: fragment [
	"Find and return the Unicode Character Data objects whose official name matches fragment."
	
	"self nameMatching: 'CAPITAL LETTER A'"
	
	| matches |
	matches := Array streamContents: [ :out |
		self database valuesDo: [ :each |
			"Note that by using #names both #name and #oldName if any will be used"
			(each names findString: fragment startingAt: 1 caseSensitive: false) ~= 0
				ifTrue: [ out nextPut: each ] ] ].
	^ matches
]

{ #category : #queries }
UnicodeCharacterData class >> named: fullName [
	"Find and return the Unicode Character Data object whose official name is fullName."
	
	"self named: 'LATIN CAPITAL LETTER A'"
	
	self database valuesDo: [ :each |
		each name = fullName ifTrue: [ ^ each ] ].
	NotFound signalFor: fullName in: self 
]

{ #category : #queries }
UnicodeCharacterData class >> nonStarterDecompositions [
	"D111"
	
	^ self database values select: #isNonStarterDecomposition
]

{ #category : #'accessing - datasets' }
UnicodeCharacterData class >> normalizationQuickCheck [
	^ NormalizationQuickCheck ifNil: [ NormalizationQuickCheck := self loadNormalizationQuickCheck ]
]

{ #category : #'accessing - normalization quick check' }
UnicodeCharacterData class >> normalizationQuickCheck: property forCodePoint: codePoint [
	"Return #Y (yes), #N (no) or #M (maybe) for property, #NFC_QC, #NFD_QC, #NFKC_QC or #NFKD_QC"
	
	^ (self normalizationQuickCheck at: property) at: codePoint ifAbsent: [ #Y ] 
]

{ #category : #'accessing - normalization quick check' }
UnicodeCharacterData class >> normalizationQuickCheck: property forCodePointStream: codePointStream [
	| result lastCCC codePoint ccc check |
	result := #Y.
	lastCCC := 0.
	[ codePointStream atEnd ] whileFalse: [
		codePoint := codePointStream next.
		"(self isSupplementaryCodePoint: codePoint) ifTrue: [ codePointStream next ]."
		ccc := [ codePoint unicodeCharacterData ccc ] on: NotFound do: [ 0 ].
		(lastCCC > ccc and: [ ccc ~= 0 ]) ifTrue: [ ^ #N ].
		check := self normalizationQuickCheck: property forCodePoint: codePoint.
		check = #N ifTrue: [ ^ #N ].
		check = #M ifTrue: [ result := #M ]. 
		lastCCC := ccc ].
	^ result
]

{ #category : #'accessing - normalization quick check' }
UnicodeCharacterData class >> normalizationQuickCheck: property forString: string [
	^ self 
		normalizationQuickCheck: property 
		forCodePointStream: string readStream unicodeCodePoints
]

{ #category : #'private - derived normalization properties' }
UnicodeCharacterData class >> parseDerivedNormalizationProperty: line [
	| fields range value comment |
	fields := $; split: (line copyFrom: 1 to: (line indexOf: $#) - 1).
	comment := line copyFrom: (line indexOf: $#) + 2 to: line size.
	range := fields first trimBoth.
	range := (range indexOfSubCollection: '..' startingAt: 1 ifAbsent: [ ])
		ifNil: [ Integer readFrom: range base: 16 ]
		ifNotNil: [ :ellipsis | 
				(Integer readFrom: (range copyFrom: 1 to: ellipsis - 1) base: 16) 
					to: (Integer readFrom: (range copyFrom: ellipsis + 2 to: range size) base: 16) ].
	value := fields size = 2
					ifTrue: [ true ]
					ifFalse: [ fields third trimBoth asSymbol ].
	^ { 
		#range -> range.
		#property -> fields second trimBoth asSymbol.
		#value -> value.
		#comment -> comment trimBoth } asDictionary
]

{ #category : #'private - database' }
UnicodeCharacterData class >> parseUnicodeCharacterData: line [
	| fields isCompact concreteClass |
	fields := $; split: line.
	"Test if the fields for decomposition, numerical and case mapping are all empty"
	isCompact := #(6 7 8 9 13 14 15) allSatisfy: [ :each | (fields at: each) isEmpty ].
	concreteClass := isCompact 
		ifTrue: [ UnicodeCharacterData ] 
		ifFalse: [ UnicodeCharacterDataExtended ].
	^ concreteClass new
		initializeFrom: fields;
		yourself
]

{ #category : #'private - jamo short names' }
UnicodeCharacterData class >> parseUnicodeJamoShortNames: aLine [
	| codePoint start end shortName |
	"Don't parse comments and empty lines"
	(aLine isEmpty or: [aLine first = $#]) ifTrue: [ ^nil ].
	"All lines are in format CODEPOINT; SHORTNAME #LONGNAME "
	codePoint := Number readFrom: aLine base: 16.
	start := (aLine indexOf: $;) + 2.
	end := (aLine indexOf: Character space startingAt: start) -1.
	shortName := aLine copyFrom: start to: end.
	^codePoint -> shortName	 
]

{ #category : #initialization }
UnicodeCharacterData class >> resetDataSets [
	"self resetDataSets"

	UnicodeCharacterDatabase := nil.
	SpecialRanges := nil.
	JamoShortNames := nil.
	NormalizationQuickCheck := nil.
	CompositionExclusions := nil
]

{ #category : #'private - hangul' }
UnicodeCharacterData class >> resetHangulDatabase [
	^ HangulCache ifNotNil: [ HangulCache removeAll ]
]

{ #category : #queries }
UnicodeCharacterData class >> singletons [
	"D110"
	
	^ self database values select: #isSingleton
]

{ #category : #'accessing - datasets' }
UnicodeCharacterData class >> specialRanges [
	SpecialRanges ifNil: [ self initializeDatabase ].
	^ SpecialRanges
]

{ #category : #'private - database common' }
UnicodeCharacterData class >> unicodeCharacterDatabaseBaseUrl [
	"Return the base of URL where all files of the UCD dataset can be found"
	
	^ 'http://www.unicode.org/Public/UNIDATA' asZnUrl
]

{ #category : #'private - database common' }
UnicodeCharacterData class >> unicodeCharacterDatabaseCacheDirectory [
	"Return the directory where a local filesystem copy of the UCD data is stored.
	Decompress http://www.unicode.org/Public/UNIDATA/UCD.zip next to your image"
	
	^ FileLocator imageDirectory / #UCD
]

{ #category : #'private - database' }
UnicodeCharacterData class >> unicodeCharacterDatabaseFile [
	"Return the name of the main Unicode Character Database specification file"
	
	^ 'UnicodeData.txt'
]

{ #category : #queries }
UnicodeCharacterData class >> unmappedDecompositionCodePoints [
	^ (Array streamContents: [ :out | 
			self database valuesDo: [ :ucd | 
				ucd decompositionMappingDo: [ :each | 
					self forCodePoint: each ifAbsent: [ out nextPut: each ] ] ] ]) asSet sorted
]

{ #category : #queries }
UnicodeCharacterData class >> unmappedDecompositions [
	^ (self database values select: [ :ucd | 
			| missing |
			missing := false.
			ucd decompositionMappingDo: [ :each |
				self forCodePoint: each ifAbsent: [ missing := true ] ]. 
			missing ]) sorted
]

{ #category : #comparing }
UnicodeCharacterData >> <= otherUnicodeCharacterData [
	^ self codePoint <= otherUnicodeCharacterData codePoint
]

{ #category : #comparing }
UnicodeCharacterData >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ codePoint = anObject codePoint
]

{ #category : #accessing }
UnicodeCharacterData >> bidirectionalCategory [
	"Return the symbol indicating the Bidirection Category of my codepoint"

	| index |
	index := (bitEncodedFields >> 13) bitAnd: 2r11111.
	^ self class bidirectionalCategories at: index + 1
]

{ #category : #accessing }
UnicodeCharacterData >> canonicalCombiningClass [
	"Return the integer indicating the Canonical Combining Class of my codepoint"

	^ bitEncodedFields bitAnd: 16rFF
]

{ #category : #accessing }
UnicodeCharacterData >> caseMapping [
	"If not nil, a 3 element array: { upper. lower. title } each of which could be nil.
	Use the accessors #uppercase, #lowercase or #titlecase instead"
	
	^ nil
]

{ #category : #accessing }
UnicodeCharacterData >> ccc [
	"A shorter alias"
	
	^ self canonicalCombiningClass 
]

{ #category : #accessing }
UnicodeCharacterData >> character [
	"Return a character instance corresponding to my codepoint"

	^ Character codePoint: codePoint
]

{ #category : #accessing }
UnicodeCharacterData >> codePoint [
	"Return my codepoint, an integer"
	
	^ codePoint
]

{ #category : #accessing }
UnicodeCharacterData >> decimalDigitValue [
	"Return the decimal digit value of my codepoint as an integer. Could be nil if not applicable."
	
	^ self numericMapping ifNotNil: [ :numericMapping | numericMapping first ]
]

{ #category : #'gt-inspector-extension' }
UnicodeCharacterData >> decompositionAsUCDs [
	^ self decompositionMapping ifNotNil: [ :decomposition | 
			decomposition collect: [ :each | 
				each isInteger 
					ifTrue: [ 
						self class 
							forCodePoint: each 
							ifAbsent: [ 
								self class new 
									initializeDegenerate: each;
									yourself ] ]
					ifFalse: [ each ] ] ]
]

{ #category : #'gt-inspector-extension' }
UnicodeCharacterData >> decompositionDescription [
	^ String streamContents: [ :out |
			self decompositionMapping ifNotNil: [ :mapping | 
				| decomposition |
				mapping first isInteger 
					ifTrue: [ decomposition := mapping ]
					ifFalse: [ 
						out << $< << mapping first << $>; space. 
						decomposition := mapping allButFirst ].
			decomposition 
				do: [ :each | out nextPut: (Character codePoint: each) ]
				separatedBy: [ out << ' + ' ] ] ]
]

{ #category : #accessing }
UnicodeCharacterData >> decompositionMapping [
	"Return my decomposition mapping if applicable, an array of code points, with an optional symbol tag in the first position. The code points of my decomposition can be combined into my codepoint."
	
	^ nil
]

{ #category : #accessing }
UnicodeCharacterData >> decompositionMappingDo: block [
	"Execute block for each code point in my decomposition mapping, if any"
	
	self hasCanonicalDecomposition 
		ifTrue: [ ^ self decompositionMapping do: block ].
	self hasCompatibleDecomposition 
		ifTrue: [ ^ self decompositionMapping allButFirstDo: block ]
]

{ #category : #accessing }
UnicodeCharacterData >> decompositionString [
	"Return my decomposition as a String, if I have none, return an empty string."
	
	^ String streamContents: [ :out |
			self decompositionMappingDo: [ :each | 
				out nextPut: (Character codePoint: each) ] ]
]

{ #category : #accessing }
UnicodeCharacterData >> digitValue [
	"Return the digit value of my codepoint as an integer. Could be nil if not applicable."

	^ self numericMapping ifNotNil: [ :numericMapping | numericMapping second ]
]

{ #category : #accessing }
UnicodeCharacterData >> generalCategory [
	"Return the symbol indicating the General Category of my codepoint"

	| index |
	index := (bitEncodedFields >> 8) bitAnd: 2r11111.
	^ self class generalCategories at: index + 1
]

{ #category : #'gt-inspector-extension' }
UnicodeCharacterData >> gtInspectorCharacterIn: composite [
	<gtInspectorPresentationOrder: 30>
	^ composite table
		title: 'Character';
		display: [
			{
				{ 'codepoint'. self codePoint }.
				{ 'codepoint hex'. 
					String streamContents: [ :stream | 
						stream << 'U+'.
						self codePoint printOn: stream base: 16 nDigits: 4 ].
					self codePoint }.
				{ 'character'. self character printString. self character }.
				{ 'name'. self name }.
				{ 'old name'. self oldName ifNil: [ '' ]. self oldName }.
				{ 'general category'. self generalCategory }.
				{ 'canonical combining class'. self canonicalCombiningClass }.
				{ 'bidirectional category'. self bidirectionalCategory }.
				{ 'mirrored'. self mirrored }.
				{ 'uppercase'. 
					self uppercase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self uppercase ifAbsent: [] }.
				{ 'lowercase'. 
					self lowercase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self lowercase ifAbsent: [] }.
				{ 'titlecase'. 
					self titlecase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self titlecase ifAbsent: [] }.
				{ 'decimal digit value'. self decimalDigitValue ifNil: [ '' ]. self decimalDigitValue }.
				{ 'digit value'. self digitValue ifNil: [ '' ]. self digitValue }.
				{ 'numeric value'. self numericValue ifNil: [ '' ]. self numericValue }.
				{ 'decomposition'. self decompositionDescription. self decompositionAsUCDs }
			} ];
		column: 'Key' evaluated: #first;
		column: 'Value' evaluated: [ :entry | entry second asString ];
		send: [ :entry | entry at: 3 ifAbsent: [ entry second ] ]
]

{ #category : #'gt-inspector-extension' }
UnicodeCharacterData >> gtInspectorGlyphIn: composite [
	<gtInspectorPresentationOrder: 40>
	^ self character gtInspectorGlyphIn: composite
]

{ #category : #testing }
UnicodeCharacterData >> hasCanonicalDecomposition [
	^ self hasDecomposition and: [ self decompositionMapping first isInteger ]
]

{ #category : #testing }
UnicodeCharacterData >> hasCompatibleDecomposition [
	^ self hasDecomposition and: [ self decompositionMapping first isSymbol ]
]

{ #category : #testing }
UnicodeCharacterData >> hasDecomposition [
	^ false
]

{ #category : #testing }
UnicodeCharacterData >> hasStandardCanonicalDecomposition [
	^ self hasCanonicalDecomposition and: [ self decompositionMapping size = 2 ]
]

{ #category : #comparing }
UnicodeCharacterData >> hash [
	^ codePoint hash
]

{ #category : #private }
UnicodeCharacterData >> initializeBitEncodedFieldsFrom: fields [
	| generalCategory canonicalCombiningClass bidirectionalCategory mirrored generalIndex bidiIndex |
	generalCategory := fields third asSymbol.
	canonicalCombiningClass := fields fourth asNumber.
	bidirectionalCategory := fields fifth asSymbol.
	mirrored := (fields at: 10) first = $Y.
	generalIndex := self class generalCategories 
		indexOf: generalCategory ifAbsent: [ NotFound signalFor: generalCategory ].
	bidiIndex := self class bidirectionalCategories 
		indexOf: bidirectionalCategory ifAbsent: [ NotFound signalFor: bidirectionalCategory ].
	bitEncodedFields := canonicalCombiningClass 
		+ (generalIndex - 1 << 8) 
		+ (bidiIndex - 1 << 13)
		+ (mirrored asBit << 18)
]

{ #category : #initialize }
UnicodeCharacterData >> initializeDegenerate: integer [
	codePoint := integer.
	name := '<UNKNOWN>'.
	bitEncodedFields := 0
]

{ #category : #initialize }
UnicodeCharacterData >> initializeFrom: fields [
	codePoint := Integer readFrom: fields first base: 16.
	name := fields second.
	(fields at: 11) ifNotEmpty: [ :oldname | 
		name := name, Character tab asString, oldname ].
	self initializeBitEncodedFieldsFrom: fields.

]

{ #category : #testing }
UnicodeCharacterData >> isCompositionExclusion [
	^ self class compositionExclusions includes: codePoint 
]

{ #category : #testing }
UnicodeCharacterData >> isFullCompositionExclusion [
	^ self isSingleton or: [ self isNonStarterDecomposition or: [ self isCompositionExclusion ] ]
]

{ #category : #testing }
UnicodeCharacterData >> isLetter [
	^ self generalCategory first = $L
]

{ #category : #testing }
UnicodeCharacterData >> isLowercase [
	^ self generalCategory = #Ll
]

{ #category : #testing }
UnicodeCharacterData >> isMark [
	^ self generalCategory first = $M
]

{ #category : #testing }
UnicodeCharacterData >> isNonStarterDecomposition [
	^ self hasCanonicalDecomposition 
			and: [ self isSingleton not
				and: [ 
					self isStarter not 
						or: [ (self class forCodePoint: self decompositionMapping first) isStarter not ] ] ]
]

{ #category : #testing }
UnicodeCharacterData >> isNumber [
	^ self generalCategory first = $N
]

{ #category : #testing }
UnicodeCharacterData >> isNumberDecimal [
	^ self generalCategory = #Nd
]

{ #category : #testing }
UnicodeCharacterData >> isNumberLetter [
	^ self generalCategory = #Nl
]

{ #category : #testing }
UnicodeCharacterData >> isNumberOther [
	^ self generalCategory = #No
]

{ #category : #testing }
UnicodeCharacterData >> isOther [
	^ self generalCategory first = $C
]

{ #category : #testing }
UnicodeCharacterData >> isPrimaryComposite [
	^ self hasCanonicalDecomposition and: [ self isFullCompositionExclusion not ]
]

{ #category : #testing }
UnicodeCharacterData >> isPunctuation [
	^ self generalCategory first = $P
]

{ #category : #testing }
UnicodeCharacterData >> isSeparator [
	^ self generalCategory first = $Z
]

{ #category : #testing }
UnicodeCharacterData >> isSingleton [
	^ self hasCanonicalDecomposition and: [ self decompositionMapping size = 1 ]
]

{ #category : #testing }
UnicodeCharacterData >> isStarter [
	^ self canonicalCombiningClass = 0
]

{ #category : #testing }
UnicodeCharacterData >> isSymbol [
	^ self generalCategory first = $S
]

{ #category : #testing }
UnicodeCharacterData >> isTitlecase [
	^ self generalCategory = #Lt
]

{ #category : #testing }
UnicodeCharacterData >> isUppercase [
	^ self generalCategory = #Lu
]

{ #category : #accessing }
UnicodeCharacterData >> jamoShortName [
	"As the name only exists for the few hangul base characters, they are kept in a separate table, rather than as general properties"
	
	^ self class jamoShortNames at: self codePoint ifAbsent: ''
]

{ #category : #accessing }
UnicodeCharacterData >> lowercase [
	"Return the codepoint of the lowercase version of my codepoint. Could be nil if not applicable"
	
	^ self caseMapping ifNotNil: [ :caseMapping | caseMapping second ]
]

{ #category : #accessing }
UnicodeCharacterData >> mirrored [
	"Return if my codepoint is mirrored or not"
	
	^ (bitEncodedFields bitAt: 19) = 1
]

{ #category : #accessing }
UnicodeCharacterData >> name [
	"Return my official name"
	
	| tabIndex |
	tabIndex := name indexOf: Character tab ifAbsent: [ ^ name ].
	^ name copyFrom: 1 to: tabIndex - 1
]

{ #category : #accessing }
UnicodeCharacterData >> names [
	"Return our internal name(s) representation <NAME><TAB>[<OLD-NAME>]"
	
	^ name
]

{ #category : #accessing }
UnicodeCharacterData >> numericMapping [
	"If not nil, a 3 element array: { decimalDigit. digit. numeric } each of which could be nil.
	Use the accessors #decimalDigitValue, #digitValue or #numericValue instead"

	^ nil
]

{ #category : #accessing }
UnicodeCharacterData >> numericValue [
	"Return the numeric value of my codepoint as an integer. Could be nil if not applicable."

	^ self numericMapping ifNotNil: [ :numericMapping | numericMapping third ]
]

{ #category : #accessing }
UnicodeCharacterData >> oldName [
	"Return my old/legacy name, could be nil"
	
	| tabIndex |
	tabIndex := name indexOf: Character tab ifAbsent: [ ^ nil ].
	^ name copyFrom: tabIndex + 1 to: name size
]

{ #category : #printing }
UnicodeCharacterData >> printOn: stream [
	stream << 'U+'.
	self codePoint printOn: stream base: 16 nDigits: 4.
	stream space; << self name.
	self oldName ifNotNil: [ stream space; nextPut: $(; << self oldName; nextPut: $) ]
]

{ #category : #'gt-spotter-extension' }
UnicodeCharacterData >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	^ aComposite table
		title: 'Unicode Character';
		display: [
			{
				{ 'codepoint'. self codePoint }.
				{ 'codepoint hex'. 
					String streamContents: [ :stream | 
						stream << 'U+'.
						self codePoint printOn: stream base: 16 nDigits: 4 ].
					self codePoint }.
				{ 'character'. self character printString. self character }.
				{ 'name'. self name }.
				{ 'old name'. self oldName ifNil: [ '' ]. self oldName }.
				{ 'general category'. self generalCategory }.
				{ 'canonical combining class'. self canonicalCombiningClass }.
				{ 'bidirectional category'. self bidirectionalCategory }.
				{ 'mirrored'. self mirrored }.
				{ 'uppercase'. 
					self uppercase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self uppercase ifAbsent: [] }.
				{ 'lowercase'. 
					self lowercase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self lowercase ifAbsent: [] }.
				{ 'titlecase'. 
					self titlecase ifNotNil: [ :n | Character codePoint: n ] ifNil: [ '' ]. 
					self class forCodePoint: self titlecase ifAbsent: [] }.
				{ 'decimal digit value'. self decimalDigitValue ifNil: [ '' ]. self decimalDigitValue }.
				{ 'digit value'. self digitValue ifNil: [ '' ]. self digitValue }.
				{ 'numeric value'. self numericValue ifNil: [ '' ]. self numericValue }.
				{ 'decomposition'. self decompositionDescription. self decompositionAsUCDs }
			} ];
		column: 'Key' evaluated: #first;
		column: 'Value' evaluated: [ :entry | entry second asString ];
		entity: self
]

{ #category : #accessing }
UnicodeCharacterData >> titlecase [
	"Return the codepoint of the titlecase version of my codepoint. Could be nil if not applicable"

	^ self caseMapping ifNotNil: [ :caseMapping | caseMapping third ]
]

{ #category : #accessing }
UnicodeCharacterData >> uppercase [
	"Return the codepoint of the uppercase version of my codepoint. Could be nil if not applicable"

	^ self caseMapping ifNotNil: [ :caseMapping | caseMapping first ]
]
