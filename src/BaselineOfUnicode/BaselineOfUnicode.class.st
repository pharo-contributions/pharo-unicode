Class {
	#name : #BaselineOfUnicode,
	#superclass : #BaselineOf,
	#category : #BaselineOfUnicode
}

{ #category : #baselines }
BaselineOfUnicode >> baseline: spec [ 
	<baseline>

	spec for: #common do: [
		spec 
			package: 'Unicode-Character-Data';
			package: 'Unicode-Stream-Support';
			package: 'Unicode-Casing' with: [ 
				spec requires: #('Unicode-Character-Data' 'Unicode-Stream-Support') ];
			package: 'Unicode-Normalization' with: [ 
				spec requires: #('Unicode-Character-Data' 'Unicode-Stream-Support') ];
			package: 'Unicode-Collate' with: [ 
				spec requires: #('Unicode-Normalization') ];

			package: 'Unicode-Tests-Character-Data' with: [ 
				spec requires: 'Unicode-Character-Data' ];
			package: 'Unicode-Tests-Casing' with: [ 
				spec requires: 'Unicode-Casing' ];
			package: 'Unicode-Tests-Normalization' with: [ 
				spec requires: 'Unicode-Normalization' ];
			package: 'Unicode-Tests-Collate' with: [ 
				spec requires: 'Unicode-Collate' ];

			group: 'default' with: #('Core' 'Tests');
			
			group: 'Core' with: #(
				'Unicode-Character-Data' 'Unicode-Casing' 'Unicode-Stream-Support' 'Unicode-Normalization');
			group: 'Tests' with: #(
				'Unicode-Tests-Character-Data' 'Unicode-Tests-Casing' 'Unicode-Tests-Normalization');
			group: 'Collate' with: #(
				'Unicode-Collate' 'Unicode-Tests-Collate') ]
]
