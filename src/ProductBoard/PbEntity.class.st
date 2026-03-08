Class {
	#name : 'PbEntity',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'client'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'instance creation' }
PbEntity class >> from: aDictionary [
	| entity |
	aDictionary ifNil: [ ^ nil ].
	(aDictionary isKindOf: self) ifTrue: [ ^ aDictionary ].
	entity := self new.
	entity from: aDictionary.
	^ entity
]

{ #category : 'accessing' }
PbEntity class >> serializationProperties [
	^ #()
]

{ #category : 'accessing' }
PbEntity >> client [
	^ client
]

{ #category : 'accessing' }
PbEntity >> client: anObject [
	client := anObject
]

{ #category : 'serialization' }
PbEntity >> deserializeTime: anObject [
	anObject ifNil: [ ^ nil ].
	(anObject isKindOf: DateAndTime) ifTrue: [ ^ anObject ].
	(anObject isKindOf: Number) ifTrue: [ ^ DateAndTime fromUnixTime: anObject ].
	(anObject isKindOf: String) ifTrue: [ 
		^ [ DateAndTime fromString: anObject ] on: Error do: [ anObject ] ].
	^ anObject
]

{ #category : 'as yet unclassified' }
PbEntity >> from: aDictionary [
	self rawData: aDictionary.

	self class serializationProperties
		do: [ :aPair | 
			self
				perform: (aPair value , ':') asSymbol
				withArguments: {aDictionary at: aPair key ifAbsent: [ nil ]} ]
]

{ #category : 'accessing' }
PbEntity >> gtViewRawDataFor: aView [
	<gtView>
	self rawData ifNil: [^ aView empty ].

	^ aView forward
		title: 'Raw data';
		priority: 10;
		object: [ self rawData ];
		view: #gtItemsFor:
]

{ #category : 'as yet unclassified' }
PbEntity >> merge: anotherEntity [
	self rawData: anotherEntity rawData.

	self class serializationProperties
		do: [ :aPair | 
			| aValue |
			aValue := anotherEntity perform: aPair value.
			aValue
				ifNotNil: [ self perform: (aPair value , ':') asSymbol withArguments: {aValue} ] ]
]

{ #category : 'as yet unclassified' }
PbEntity >> rawData [
	^ rawData
]

{ #category : 'as yet unclassified' }
PbEntity >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
PbEntity >> serialize [
	^ (self class serializationProperties
		collect: [ :aPair | aPair key -> (self perform: aPair value) ]) asDictionary
		reject: #isNil
]
