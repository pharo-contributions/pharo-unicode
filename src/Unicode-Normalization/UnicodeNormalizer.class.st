"
I am UnicodeNormalizer, I implement the normalize operation which transforms Unicode text into an equivalent composed or decomposed normal form, allowing for easier comparing, searching and sorting of text. 

I implement the forms NFC, NFD, NFKC and NFKD.

I can handle String and code point collections.

This is a high level interface that applies two fast path optimalizations:

 - don't do work on ASCII or Latin1 string when it is not needed
 - do a normalization quick check to see if normalization is really needed

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeNormalizer,
	#superclass : #Object,
	#category : #'Unicode-Normalization'
}

{ #category : #public }
UnicodeNormalizer >> composeString: string [
	"Return the NFC of string, the canonical composition normal form"
	
	(self isAlreadyNFC: string) ifTrue: [ ^ string ]. 
	^ string readStream unicodeCodePoints unicodeNFC unicodeCharacters upToEnd
]

{ #category : #public }
UnicodeNormalizer >> composeStringCompatible: string [
	"Return the NFKC of string, the compatible composition normal form"
	
	(self isAlreadyNFKC: string) ifTrue: [ ^ string ]. 
	^ string readStream unicodeCodePoints unicodeNFKC unicodeCharacters upToEnd
]

{ #category : #public }
UnicodeNormalizer >> decomposeString: string [
	"Return the NFD of string, the canonical decomposition normal form"
	
	(self isAlreadyNFD: string) ifTrue: [ ^ string ]. 
	^ string readStream unicodeCodePoints unicodeNFD unicodeCharacters upToEnd
]

{ #category : #public }
UnicodeNormalizer >> decomposeStringCompatible: string [
	"Return the NFKD of string, the compatible decomposition normal form"
	
	(self isAlreadyNFKD: string) ifTrue: [ ^ string ]. 
	^ string readStream unicodeCodePoints unicodeNFKD unicodeCharacters upToEnd
]

{ #category : #testing }
UnicodeNormalizer >> isAlreadyNFC: string [
	"Return true when we know string is already in NFC form, false otherwise.
	This uses a quick check algorithm.
	False means we don't know, but it is still possible. 
	The only way to know for sure is to do the actual conversion."
	
	"Latin1 strings are always in NFC"
	^ string isByteString or: [ 
		(UnicodeCharacterData normalizationQuickCheck: #NFC_QC forString: string) = #Y ]
]

{ #category : #testing }
UnicodeNormalizer >> isAlreadyNFD: string [
	"Return true when we know string is already in NFD form, false otherwise.
	This uses a quick check algorithm.
	False means we don't know, but it is still possible. 
	The only way to know for sure is to do the actual conversion."

	"ASCII strings are always in NFD"
	^ (string isByteString and: [ string isAsciiString ])
		or: [ (UnicodeCharacterData normalizationQuickCheck: #NFD_QC forString: string) = #Y ]
]

{ #category : #testing }
UnicodeNormalizer >> isAlreadyNFKC: string [
	"Return true when we know string is already in NFKC form, false otherwise.
	This uses a quick check algorithm.
	False means we don't know, but it is still possible. 
	The only way to know for sure is to do the actual conversion."

	"ASCII strings are always in NFKC"
	^ (string isByteString and: [ string isAsciiString ])
		or: [ (UnicodeCharacterData normalizationQuickCheck: #NFKC_QC forString: string) = #Y ]
]

{ #category : #testing }
UnicodeNormalizer >> isAlreadyNFKD: string [
	"Return true when we know string is already in NFKD form, false otherwise.
	This uses a quick check algorithm.
	False means we don't know, but it is still possible. 
	The only way to know for sure is to do the actual conversion."

	"ASCII strings are always in NFKD"
	^ (string isByteString and: [ string isAsciiString ])
		or: [ (UnicodeCharacterData normalizationQuickCheck: #NFKD_QC forString: string) = #Y ]
]

{ #category : #testing }
UnicodeNormalizer >> isNFC: string [
	"Return true when string is in NFC form, false otherwise"
	
	^ string = (self toNFC: string)
]

{ #category : #testing }
UnicodeNormalizer >> isNFD: string [
	"Return true when string is in NFD form, false otherwise"
	
	^ string = (self toNFD: string)
]

{ #category : #testing }
UnicodeNormalizer >> isNFKC: string [
	"Return true when string is in NFC form, false otherwise"
	
	^ string = (self toNFKC: string)
]

{ #category : #testing }
UnicodeNormalizer >> isNFKD: string [
	"Return true when string is in NFKD form, false otherwise"
	
	^ string = (self toNFKD: string)
]

{ #category : #public }
UnicodeNormalizer >> toNFC: string [
	^ self composeString: string
]

{ #category : #public }
UnicodeNormalizer >> toNFD: string [
	^ self decomposeString: string
]

{ #category : #public }
UnicodeNormalizer >> toNFKC: string [
	^ self composeStringCompatible: string
]

{ #category : #public }
UnicodeNormalizer >> toNFKD: string [
	^ self decomposeStringCompatible: string
]
