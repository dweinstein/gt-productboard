Class {
	#name : 'PbListObjectivesAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'as yet unclassified' }
PbListObjectivesAPIClient >> request [
	^ self client get: '/objectives'
]

{ #category : 'as yet unclassified' }
PbListObjectivesAPIClient >> serializationClass [
	^ PbObjectivesGroup
]
