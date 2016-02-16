"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestUnicodeCollate,
	#superclass : #PackageManifest,
	#category : #'Unicode-Collate'
}

{ #category : #'code-critics' }
ManifestUnicodeCollate class >> ruleRBExtraBlockRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'UnicodeDUCETData class' #addTibetanContractionsTo: #true)) #'2016-02-16T22:55:22.308571+01:00') )
]

{ #category : #'code-critics' }
ManifestUnicodeCollate class >> ruleRBToDoCollectRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#CollateSequence #elements #false)) #'2016-02-16T18:32:40.521609+01:00') )
]
