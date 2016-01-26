Extension { #name : #CodePointFromCharacterReadStream }

{ #category : #'*unicode-normalization' }
CodePointFromCharacterReadStream >> unicodeCompose [
	"Return a UnicodeComposingReadStream over the receiver that streams over Integer code points after composing them"
	
	^ UnicodeComposingReadStream on: self
]

{ #category : #'*unicode-normalization' }
CodePointFromCharacterReadStream >> unicodeNFC [
	"Return a UnicodeComposingReadStream over the receiver that streams over Integer code points composing them after decomposing them canonically"
	
	^ (UnicodeNFDReadStream on: self) unicodeCompose
]

{ #category : #'*unicode-normalization' }
CodePointFromCharacterReadStream >> unicodeNFD [
	"Return a UnicodeNFDReadStream over the receiver that streams over Integer code points after decomposing them canonically"
	
	^ UnicodeNFDReadStream on: self
]

{ #category : #'*unicode-normalization' }
CodePointFromCharacterReadStream >> unicodeNFKC [
	"Return a UnicodeComposingReadStream over the receiver that streams over Integer code points composing them after decomposing them compatibly"
	
	^ (UnicodeNFKDReadStream on: self) unicodeCompose
]

{ #category : #'*unicode-normalization' }
CodePointFromCharacterReadStream >> unicodeNFKD [
	"Return a UnicodeNFKDReadStream over the receiver that streams over Integer code points after decomposing them compatibly"
	
	^ UnicodeNFKDReadStream on: self
]
