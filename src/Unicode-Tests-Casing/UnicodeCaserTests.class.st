Class {
	#name : #UnicodeCaserTests,
	#superclass : #TestCase,
	#instVars : [
		'caser'
	],
	#category : #'Unicode-Tests-Casing'
}

{ #category : #running }
UnicodeCaserTests >> setUp [
	caser := UnicodeCaser new
]

{ #category : #testing }
UnicodeCaserTests >> testLowercase [
	self assert: (caser case: #lowercase string: 'ABC') equals: 'abc'.
	self assert: (caser case: #lowercase string: '123 != abc') equals: '123 != abc'.
]

{ #category : #testing }
UnicodeCaserTests >> testUppercase [
	self assert: (caser case: #uppercase string: 'abc') equals: 'ABC'.
	self assert: (caser case: #uppercase string: '123 != ABC') equals: '123 != ABC'.
]
