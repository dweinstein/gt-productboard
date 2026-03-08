Class {
	#name : 'PbListFeatureReleaseAssignmentsAPIClient',
	#superclass : 'PbEndpointClient',
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'api' }
PbListFeatureReleaseAssignmentsAPIClient >> perform [
	"Return the raw collection of assignment dictionaries."
	^ self performAll
]

{ #category : 'api' }
PbListFeatureReleaseAssignmentsAPIClient >> performAll [
	"Fetch all pages and return a raw OrderedCollection of assignment dictionaries.
	No entity/group class needed — these are just ID mappings (featureId -> releaseId)."
	| allData result nextUrl links |
	allData := OrderedCollection new.
	result := self request.
	allData addAll: (result at: 'data').
	[ 
		links := result at: 'links' ifAbsent: [ nil ].
		nextUrl := links ifNotNil: [ links at: 'next' ifAbsent: [ nil ] ].
		nextUrl notNil
	] whileTrue: [
		result := self client getUrl: nextUrl.
		allData addAll: (result at: 'data')
	].
	^ allData
]

{ #category : 'api' }
PbListFeatureReleaseAssignmentsAPIClient >> request [
	^ self client get: '/feature-release-assignments'
]
