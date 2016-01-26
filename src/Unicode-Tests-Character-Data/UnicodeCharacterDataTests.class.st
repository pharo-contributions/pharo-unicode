Class {
	#name : #UnicodeCharacterDataTests,
	#superclass : #TestCase,
	#category : #'Unicode-Tests-Character-Data'
}

{ #category : #testing }
UnicodeCharacterDataTests >> testDigitOne [
	| unicodeCharacterData |
	unicodeCharacterData := $1 unicodeCharacterData.
	self assert: unicodeCharacterData codePoint equals: 49.
	self assert: unicodeCharacterData character equals: $1.
	self assert: unicodeCharacterData name equals: 'DIGIT ONE'.
	self assert: unicodeCharacterData isNumber.
	self deny: unicodeCharacterData isLetter.
	self assert: unicodeCharacterData isNumberDecimal.
	self assert: unicodeCharacterData decimalDigitValue equals: 1
]

{ #category : #testing }
UnicodeCharacterDataTests >> testLatinCapitalLetterA [
	| unicodeCharacterData |
	unicodeCharacterData := $A unicodeCharacterData.
	self assert: unicodeCharacterData codePoint equals: 65.
	self assert: unicodeCharacterData character equals: $A.
	self assert: unicodeCharacterData name equals: 'LATIN CAPITAL LETTER A'.
	self assert: unicodeCharacterData isLetter.
	self deny: unicodeCharacterData isNumber.
	self assert: unicodeCharacterData isUppercase.
	self assert: unicodeCharacterData lowercase equals: $a codePoint
]

{ #category : #testing }
UnicodeCharacterDataTests >> testLatinSmallLetterA [
	| unicodeCharacterData |
	unicodeCharacterData := $a unicodeCharacterData.
	self assert: unicodeCharacterData codePoint equals: 97.
	self assert: unicodeCharacterData character equals: $a.
	self assert: unicodeCharacterData name equals: 'LATIN SMALL LETTER A'.
	self assert: unicodeCharacterData isLetter.
	self deny: unicodeCharacterData isNumber.
	self assert: unicodeCharacterData isLowercase.
	self assert: unicodeCharacterData uppercase equals: $A codePoint
]

{ #category : #testing }
UnicodeCharacterDataTests >> testLatinSmallLetterEWithAcute [
	| unicodeCharacterData |
	unicodeCharacterData := $é unicodeCharacterData.
	"LATIN SMALL LETTER E WITH ACUTE [U+00E9]"
	self assert: unicodeCharacterData codePoint equals: 233.
	self assert: unicodeCharacterData character equals: $é.
	self assert: unicodeCharacterData name equals: 'LATIN SMALL LETTER E WITH ACUTE'.
	self assert: unicodeCharacterData isLetter.
	self deny: unicodeCharacterData isNumber.
	self assert: unicodeCharacterData isLowercase.
	self assert: unicodeCharacterData uppercase equals: $É codePoint.
	self assert: unicodeCharacterData hasStandardCanonicalDecomposition.
	"LATIN SMALL LETTER E [U+0065] followed by COMBINING ACUTE ACCENT [U+0301]"
	self assert: unicodeCharacterData decompositionMapping equals: #(101 769)
]
