Class {
	#name : 'PbInsightStore',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'name',
		'createdAt',
		'status',
		'usageBytes',
		'fileCounts'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'as yet unclassified' }
PbInsightStore class >> serializationProperties [
	^ {#id -> #id.
		#name -> #name.
		#created_at -> #createdAt.
		#status -> #status.
		#usage_bytes -> #usageBytes.
		#file_counts -> #fileCounts}
]

{ #category : 'accessing' }
PbInsightStore >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
PbInsightStore >> createdAt: aValue [
	createdAt := self deserializeTime: aValue
]

{ #category : 'accessing' }
PbInsightStore >> fileCounts [
	^ fileCounts
]

{ #category : 'accessing' }
PbInsightStore >> fileCounts: anObject [
	fileCounts := anObject
]

{ #category : 'accessing' }
PbInsightStore >> id [
	^ id
]

{ #category : 'accessing' }
PbInsightStore >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbInsightStore >> name [
	^ name
]

{ #category : 'accessing' }
PbInsightStore >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
PbInsightStore >> status [
	^ status
]

{ #category : 'accessing' }
PbInsightStore >> status: anObject [
	status := anObject
]

{ #category : 'accessing' }
PbInsightStore >> usageBytes [
	^ usageBytes
]

{ #category : 'accessing' }
PbInsightStore >> usageBytes: anObject [
	usageBytes := anObject
]
