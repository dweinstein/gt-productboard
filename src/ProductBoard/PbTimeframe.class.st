Class {
	#name : 'PbTimeframe',
	#superclass : 'PbEntity',
	#instVars : [
		'startDate',
		'endDate',
		'granularity'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbTimeframe class >> serializationProperties [
	^ {#startDate -> #startDate.
		#endDate -> #endDate.
		#granularity -> #granularity}
]

{ #category : 'accessing' }
PbTimeframe >> durationInDays [
	(startDate isNil or: [ endDate isNil ]) ifTrue: [ ^ nil ].
	^ (endDate - startDate) days
]

{ #category : 'accessing' }
PbTimeframe >> endDate [
	^ endDate
]

{ #category : 'accessing' }
PbTimeframe >> endDate: aString [
	endDate := (aString isNil or: [ aString = 'none' ])
		ifTrue: [ nil ]
		ifFalse: [ [ Date fromString: aString ] on: Error do: [ nil ] ]
]

{ #category : 'accessing' }
PbTimeframe >> granularity [
	^ granularity
]

{ #category : 'accessing' }
PbTimeframe >> granularity: anObject [
	granularity := (anObject = 'none') ifTrue: [ nil ] ifFalse: [ anObject ]
]

{ #category : 'printing' }
PbTimeframe >> gtDisplayOn: stream [
	startDate ifNotNil: [ stream nextPutAll: startDate monthName, ' ', startDate year printString ].
	endDate ifNotNil: [ 
		stream nextPutAll: ' – '.
		stream nextPutAll: endDate monthName, ' ', endDate year printString ].
	granularity ifNotNil: [ stream nextPutAll: ' (', granularity, ')' ]
]

{ #category : 'accessing' }
PbTimeframe >> startDate [
	^ startDate
]

{ #category : 'accessing' }
PbTimeframe >> startDate: aString [
	startDate := (aString isNil or: [ aString = 'none' ])
		ifTrue: [ nil ]
		ifFalse: [ [ Date fromString: aString ] on: Error do: [ nil ] ]
]
