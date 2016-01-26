Extension { #name : #Character }

{ #category : #'*unicode-character-data' }
Character >> gtInspectorGlyphIn: composite [
	<gtInspectorPresentationOrder: 60>
	^ composite morph
		title: 'Glyph';
		display: [ 
			| morph largeFont |
			"Add an extra space in front to prevent rendering glitches on combining marks"
			morph := (String space , self asString) asMorph.
			(largeFont := morph font copy)
				clearRealFont;
				pointSize: 256.
			morph font: largeFont.
			morph fitContents.
			morph ]
]

{ #category : #'*unicode-character-data' }
Character >> gtInspectorUnicodeCharacterDataIn: composite [
	<gtInspectorPresentationOrder: 40>
	| unicodeCharacterData |
	unicodeCharacterData := [ self unicodeCharacterData ] on: NotFound do: [ ^ self ].
	^ (unicodeCharacterData gtInspectorCharacterIn: composite)
			title: 'Unicode';
			yourself 
]

{ #category : #'*unicode-character-data' }
Character >> unicodeCharacterData [
	"Answer the official record from the Unicode Character Database for me"
	
	^ UnicodeCharacterData forCodePoint: self codePoint 
]
