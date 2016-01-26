Class {
	#name : #UnicodeConcatenatorTests,
	#superclass : #TestCase,
	#category : #'Unicode-Tests-Normalization'
}

{ #category : #testing }
UnicodeConcatenatorTests >> testASCII [
	self 
		assert: (UnicodeConcatenator forNFC concatenateString: 'abc' with: 'def')
		equals: 'abcdef'
	
]

{ #category : #testing }
UnicodeConcatenatorTests >> testDiacritics [
	self 
		assert: (UnicodeConcatenator forNFC concatenateString: 'éle' with: '̀ves')
		equals: 'élèves'.
	self 
		assert: (UnicodeConcatenator forNFC concatenateString: 'Ko' with: '̈nigsallee')
		equals: 'Königsallee'.
	
]

{ #category : #testing }
UnicodeConcatenatorTests >> testSimple [
	self 
		assert: (UnicodeConcatenator forNFC concatenateCodePoints: #(97 98 99 101) with: #(769 100 101 102))
		equals: #(97 98 99 233 100 101 102)
	
]
