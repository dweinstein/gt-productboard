Class {
	#name : 'PbListFeaturesAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbListFeaturesAPIClient >> request [
	^ self client get: '/features' withParams: { 'archived' -> 'false' }
]

{ #category : 'as yet unclassified' }
PbListFeaturesAPIClient >> serializationClass [
	^ PbFeaturesGroup
]
