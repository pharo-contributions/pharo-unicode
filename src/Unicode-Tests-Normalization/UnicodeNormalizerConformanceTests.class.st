"
This test uses http://www.unicode.org/Public/UNIDATA/NormalizationTest.txt to run about 75.000 individual test cases to test conformance to the official Unicode Normalization specification.
"
Class {
	#name : #UnicodeNormalizerConformanceTests,
	#superclass : #TestCase,
	#instVars : [
		'composer',
		'decomposer',
		'normalizer'
	],
	#category : #'Unicode-Tests-Normalization'
}

{ #category : #accessing }
UnicodeNormalizerConformanceTests class >> resources [
	^ Array with: UnicodeNormalizationTestResource 
]

{ #category : #running }
UnicodeNormalizerConformanceTests >> setUp [
	normalizer := UnicodeNormalizer new.
	composer := UnicodeComposer default.
	decomposer := UnicodeDecomposer new
]

{ #category : #accessing }
UnicodeNormalizerConformanceTests >> specification [
	^ UnicodeNormalizationTestResource current data
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFC [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | nfd result |
		nfd := Array streamContents: [ :out |
			decomposer decomposeFrom: (spec at: #source) readStream to: out ].
		result := Array streamContents: [ :out |
			composer composeFrom: nfd readStream to: out ].
		result = (spec at: #NFC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFC {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFCStreaming [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := (spec at: #source) readStream unicodeNFC upToEnd.
		result = (spec at: #NFC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFCStreaming {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFCString [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | in out result |
		in := (spec at: #source) collect: #asCharacter as: WideString.
		out := normalizer toNFC: in.
		result := out collect: #codePoint as: Array.
		result = (spec at: #NFC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFCString {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFD [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := Array streamContents: [ :out |
			decomposer decomposeFrom: (spec at: #source) readStream to: out ].
		result = (spec at: #NFD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFD {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFDStreaming [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := (spec at: #source) readStream unicodeNFD upToEnd.
		result = (spec at: #NFD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFDStreaming {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFDString [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | in out result |
		in := (spec at: #source) collect: #asCharacter as: WideString.
		out := normalizer toNFD: in.
		result := out collect: #codePoint as: Array.
		result = (spec at: #NFD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFDString {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKC [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | nfkd result |
		nfkd := Array streamContents: [ :out |
			decomposer decomposeCompatibleFrom: (spec at: #source) readStream to: out ].
		result := Array streamContents: [ :out |
			composer composeFrom: nfkd readStream to: out ].
		result = (spec at: #NFKC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKC {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKCStreaming [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := (spec at: #source) readStream unicodeNFKC upToEnd.
		result = (spec at: #NFKC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKCStreaming {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKCString [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | in out result |
		in := (spec at: #source) collect: #asCharacter as: WideString.
		out := normalizer toNFKC: in.
		result := out collect: #codePoint as: Array.
		result = (spec at: #NFKC)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKCString {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKD [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := Array streamContents: [ :out |
			decomposer decomposeCompatibleFrom: (spec at: #source) readStream to: out ].
		result = (spec at: #NFKD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKD {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKDStreaming [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | result |
		result := (spec at: #source) readStream unicodeNFKD upToEnd.
		result = (spec at: #NFKD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKDStreaming {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]

{ #category : #testing }
UnicodeNormalizerConformanceTests >> testNFKDString [
	| failed succeeded |
	failed := OrderedCollection new.
	succeeded := 0.
	self specification do: [ :spec | | in out result |
		in := (spec at: #source) collect: #asCharacter as: WideString.
		out := normalizer toNFKD: in.
		result := out collect: #codePoint as: Array.
		result = (spec at: #NFKD)
			ifTrue: [ succeeded := succeeded + 1 ]
			ifFalse: [ failed add: spec -> result ] ].
	self crTrace: ('#testNFKDString {1}/{2} ({3}%)' format: { 
		succeeded. self specification size. 
		succeeded / self specification size percent asFloat printShowingDecimalPlaces: 2 }).
	self assert: failed isEmpty
]
