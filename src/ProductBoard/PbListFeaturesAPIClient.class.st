Class {
	#name : 'PbListFeaturesAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'as yet unclassified' }
PbListFeaturesAPIClient >> request [
	^ self client get: '/features'
]

{ #category : 'as yet unclassified' }
PbListFeaturesAPIClient >> serializationClass [
	^ PbFeaturesGroup
]
