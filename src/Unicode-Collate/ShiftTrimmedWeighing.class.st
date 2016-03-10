"
This option is the same as Shifted, except that all trailing FFFFs are trimmed from the sort key. This could be used to emulate POSIX behavior, but is otherwise not recommended.

This has some implications on implementation; since we need a buffer to hold trailing FFFF's in addLevel:n:precededBy:to: before we decide whether they should be added.
As such, ShiftTrimmedWeighing  requires using an instance, rather than a stateless class like the other weighings.

Part of the Pharo Unicode project (http://unicode.pharo.org). Copyright (C) 2015, 2016 the Pharo Unicode contributors (Sven Van Caekenberghe, Henrik Sperre Johansen). Licensed under the MIT license (https://en.wikipedia.org/wiki/MIT_License) and for usage within Pharo (http://pharo.org).
"
Class {
	#name : #ShiftTrimmedWeighing,
	#superclass : #ShiftedWeighing,
	#instVars : [
		'possiblyTrimmed'
	],
	#classInstVars : [
		'possiblyTrimmed'
	],
	#category : #'Unicode-Collate'
}

{ #category : #accessing }
ShiftTrimmedWeighing class >> addLevel: aLevel in: aSequence precededBy: precedingSequence to: aBuffer [
	^ self
		error:
			'Shift trimmed weighing must be done with an instance of the class'
]

{ #category : #accessing }
ShiftTrimmedWeighing class >> implementor [
	"Shift-trimmed weighing requires keeping track of trailing codepoints, so we need an instance"
	^self new
]

{ #category : #accessing }
ShiftTrimmedWeighing >> addLevel: aLevel in: aSequence precededBy: precedingSequence to: aBuffer [
	|  toAdd |
	self class superclass addLevel: aLevel in: aSequence precededBy: precedingSequence to: possiblyTrimmed.
	toAdd := possiblyTrimmed size.
	possiblyTrimmed reversed detect: [:one | .
		one ~= self class terminalWeight and: 
			[toAdd := toAdd - 1. true].  ] ifNone: nil.
	^toAdd 
		timesRepeat: [ aBuffer add: possiblyTrimmed removeFirst].
]

{ #category : #'initialization-release' }
ShiftTrimmedWeighing >> initialize [
	possiblyTrimmed := OrderedCollection new.
]
