Extension { #name : #WriteStream }

{ #category : #'*unicode-stream-support' }
WriteStream >> unicodeCharacters [
	"Assuming the receiver is a stream over Integer code points, return a CharacterToCodePointWriteStream over the receiver that streams over Characters"
	
	^ CharacterToCodePointWriteStream on: self
]

{ #category : #'*unicode-stream-support' }
WriteStream >> unicodeCodePoints [
	"Assuming the receiver is a stream over Characters, return a CodePointToCharacterWriteStream over the receiver that streams over Integer code points"
	
	^ CodePointToCharacterWriteStream on: self
]
