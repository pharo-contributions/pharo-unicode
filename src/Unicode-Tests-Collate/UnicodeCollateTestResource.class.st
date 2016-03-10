"
I hold the contents of CollationTest_SHIFTED_SHORT.txt and CollationTest_NON_IGNORABLE_SHORT.txt,  loaded and unpacked from a URL: http://www.unicode.org/Public/UCA/latest/CollationTest.zip.

If running this test often, download and unzip CollationTest.zip to the image folder, and the data will be loaded from disk instead of over the network


Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #UnicodeCollateTestResource,
	#superclass : #TestResource,
	#instVars : [
		'shiftedData',
		'nonIgnorableData',
		'data'
	],
	#category : #'Unicode-Tests-Collate'
}

{ #category : #accessing }
UnicodeCollateTestResource >> getNonIgnorableRaw [
	^ self nonIgnorablePath asFileReference exists
		ifTrue:
			[ self nonIgnorablePath asFileReference
				binaryReadStreamDo: [ :bin | (ZnCharacterReadStream on: bin) upToEnd ] ]
		ifFalse:
			[ (self getRaw
				memberNamed: (FileSystem memory stringFromPath: self nonIgnorablePath)) contents ]
]

{ #category : #accessing }
UnicodeCollateTestResource >> getRaw [
	^ data ifNil: [data :=  
			(ZipArchive new readFrom: self url retrieveContents readStream)]
]

{ #category : #accessing }
UnicodeCollateTestResource >> getShiftedRaw [
	^ self shiftedPath asFileReference exists
		ifTrue:
			[ self shiftedPath asFileReference
				binaryReadStreamDo: [ :bin | (ZnCharacterReadStream on: bin) upToEnd ] ]
		ifFalse:
			[ (self getRaw
				memberNamed: (FileSystem memory stringFromPath: self shiftedPath)) contents ]
]

{ #category : #accessing }
UnicodeCollateTestResource >> nonIgnorablePath [
	"Decompress http://www.unicode.org/Public/UCA/latest/CollationTest.zip next to your image"

	^ Path * #CollationTest
		/ 'CollationTest_NON_IGNORABLE_SHORT.txt'
]

{ #category : #accessing }
UnicodeCollateTestResource >> shiftedPath [
	"Decompress http://www.unicode.org/Public/UCA/latest/CollationTest.zip next to your image"

	^ Path * #CollationTest / 'CollationTest_SHIFTED_SHORT.txt'
]

{ #category : #accessing }
UnicodeCollateTestResource >> url [
	^ 'http://www.unicode.org/Public/UCA/latest/CollationTest.zip' asZnUrl
]
