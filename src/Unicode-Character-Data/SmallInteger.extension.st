Extension { #name : #SmallInteger }

{ #category : #'*unicode-character-data' }
SmallInteger >> unicodeCharacterData [
	"Answer the official record from the Unicode Character Database for me"
	
	^ UnicodeCharacterData forCodePoint: self 
]
