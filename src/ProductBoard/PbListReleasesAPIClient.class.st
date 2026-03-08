Class {
	#name : 'PbListReleasesAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'api' }
PbListReleasesAPIClient >> request [
	^ self client get: '/releases'
]

{ #category : 'accessing' }
PbListReleasesAPIClient >> serializationClass [
	^ PbReleasesGroup
]
