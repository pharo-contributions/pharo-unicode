"
I am  Normalized Form D, Canonical Decomposition.
The valid code point sequences  code points decompose to in this form, cannot be marked as a Compatible decomposition in the Unicode database.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).

"
Class {
	#name : #UnicodeNFD,
	#superclass : #UnicodeDecomposedNormalizationForm,
	#category : #'Unicode-Normalization'
}

{ #category : #private }
UnicodeNFD class >> decompositionEntryOf: aCodePoint [
	"Return a Unicode Data Entry if it has a decomposition of my form"
	|ucd|
	ucd := [ aCodePoint unicodeCharacterData ] on: NotFound do: [nil].
	^(ucd notNil and: [ucd hasCanonicalDecomposition]) ifTrue: [ucd]
]
