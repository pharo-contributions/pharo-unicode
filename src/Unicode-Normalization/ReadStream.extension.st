Extension { #name : #ReadStream }

{ #category : #'*unicode-normalization' }
ReadStream >> unicodeCompose [
	"Assuming the receiver is a stream over Integer code points, return a UnicodeComposingReadStream over the receiver that streams over Integer code points after composing them"
	
	^ UnicodeComposingReadStream on: self
]

{ #category : #'*unicode-normalization' }
ReadStream >> unicodeNFC [
	"Assuming the receiver is a stream over Integer code points, return a UnicodeComposingReadStream over the receiver that streams over Integer code points composing them after decomposing them canonically"
	
	^ self unicodeNFD unicodeCompose
]

{ #category : #'*unicode-normalization' }
ReadStream >> unicodeNFD [
	"Assuming the receiver is a stream over Integer code points, return a UnicodeNFDReadStream over the receiver that streams over Integer code points after decomposing them canonically"
	
	^ UnicodeDecomposingReadStream nfdFormOn: self
]

{ #category : #'*unicode-normalization' }
ReadStream >> unicodeNFKC [
	"Assuming the receiver is a stream over Integer code points, return a UnicodeComposingReadStream over the receiver that streams over Integer code points composing them after decomposing them compatibly"
	
	^ self unicodeNFKD unicodeCompose
]

{ #category : #'*unicode-normalization' }
ReadStream >> unicodeNFKD [
	"Assuming the receiver is a stream over Integer code points, return a UnicodeNFKDReadStream over the receiver that streams over Integer code points after decomposing them compatibly"
	
	^ UnicodeDecomposingReadStream nfkdFormOn: self
]
