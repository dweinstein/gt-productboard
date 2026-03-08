Class {
	#name : 'BaselineOfProductboard',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfProductboard',
	#package : 'BaselineOfProductboard'
}

{ #category : 'baseline' }
BaselineOfProductboard >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'ProductBoard'
		]
]
