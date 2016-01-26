Extension { #name : #ReadStream }

{ #category : #'*unicode-stream-support' }
ReadStream >> unicodeCharacters [
	"Assuming the receiver is a stream over Integer code points, return a CharacterFromCodePointReadStream over the receiver that streams over Characters"
	
	^ CharacterFromCodePointReadStream on: self
]

{ #category : #'*unicode-stream-support' }
ReadStream >> unicodeCodePoints [
	"Assuming the receiver is a stream over Characters, return a CodePointFromCharacterReadStream over the receiver that streams over Integer code points"
	
	^ CodePointFromCharacterReadStream on: self
]
