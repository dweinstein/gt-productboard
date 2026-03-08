Class {
	#name : 'PbListReleaseGroupsAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'api' }
PbListReleaseGroupsAPIClient >> request [
	^ self client get: '/release-groups'
]

{ #category : 'accessing' }
PbListReleaseGroupsAPIClient >> serializationClass [
	^ PbReleaseGroupsGroup
]
