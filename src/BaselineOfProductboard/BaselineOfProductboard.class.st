Class {
	#name : 'BaselineOfProductboard',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfProductboard',
	#package : 'BaselineOfProductboard'
}

{ #category : 'as yet unclassified' }
BaselineOfProductboard class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt-productboard' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfProductboard >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'ProductBoard'
		]
]
