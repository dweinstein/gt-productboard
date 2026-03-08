Class {
	#name : 'PbEndpointClient',
	#superclass : 'Object',
	#instVars : [
		'client'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'accessing' }
PbEndpointClient >> client [
	^ client
]

{ #category : 'accessing' }
PbEndpointClient >> client: anObject [
	client := anObject
]

{ #category : 'accessing' }
PbEndpointClient >> perform [
	"Fetch all pages of results, auto-paginating through cursor links."
	^ self performAll
]

{ #category : 'accessing' }
PbEndpointClient >> performAll [
	"Fetch all pages by following cursor-based pagination links."
	| allData result nextUrl links combined |
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
	combined := Dictionary new.
	combined at: 'data' put: allData asArray.
	^ (self serializationClass from: combined) client: self client
]

{ #category : 'accessing' }
PbEndpointClient >> performSinglePage [
	"Fetch only the first page of results."
	| aResult |
	aResult := self request.
	^ (self serializationClass from: aResult) client: self client
]

{ #category : 'accessing' }
PbEndpointClient >> request [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
PbEndpointClient >> serializationClass [
	^ self subclassResponsibility
]
