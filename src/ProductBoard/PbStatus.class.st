Class {
	#name : 'PbStatus',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'name'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbStatus class >> serializationProperties [
	^ {#id -> #id. #name -> #name}
]

{ #category : 'printing' }
PbStatus >> gtDisplayOn: stream [
	name ifNotNil: [ stream nextPutAll: name ]
		ifNil: [ stream nextPutAll: '(no status)' ]
]

{ #category : 'gt-extensions' }
PbStatus >> gtStatusFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Status';
		priority: 1;
		items: [ rawData associations ];
		column: 'Key' text: [ :each | each key ];
		column: 'Value' text: [ :each | each value gtDisplayString ];
		send: [ :each | each value ]
]

{ #category : 'accessing' }
PbStatus >> id [
	^ id
]

{ #category : 'accessing' }
PbStatus >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbStatus >> name [
	^ name
]

{ #category : 'accessing' }
PbStatus >> name: anObject [
	name := anObject
]
