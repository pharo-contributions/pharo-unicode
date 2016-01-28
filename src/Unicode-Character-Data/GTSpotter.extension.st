Extension { #name : #GTSpotter }

{ #category : #'*unicode-character-data' }
GTSpotter >> spotterForUnicodeCharacterFor: aStep [
	<spotterOrder: 30>
	aStep listProcessor
		title: 'Unicode Character';
		allCandidates: [ UnicodeCharacterData database values ];
		itemName: [ :each | each name ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: false
]
