Class {
	#name : 'PbOwner',
	#superclass : 'PbEntity',
	#instVars : [
		'id',
		'email',
		'name'
	],
	#category : 'ProductBoard',
	#package : 'ProductBoard'
}

{ #category : 'serialization' }
PbOwner class >> serializationProperties [
	^ {#id -> #id. #email -> #email. #name -> #name}
]

{ #category : 'accessing' }
PbOwner >> email [
	^ email
]

{ #category : 'accessing' }
PbOwner >> email: anObject [
	email := anObject
]

{ #category : 'printing' }
PbOwner >> gtDisplayOn: stream [
	email ifNotNil: [ stream nextPutAll: email ]
		ifNil: [ stream nextPutAll: '(no owner)' ]
]

{ #category : 'gt-extensions' }
PbOwner >> gtOwnerFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Owner';
		priority: 1;
		items: [ rawData associations ];
		column: 'Key' text: [ :each | each key ];
		column: 'Value' text: [ :each | each value gtDisplayString ];
		send: [ :each | each value ]
]

{ #category : 'accessing' }
PbOwner >> id [
	^ id
]

{ #category : 'accessing' }
PbOwner >> id: anObject [
	id := anObject
]

{ #category : 'accessing' }
PbOwner >> name [
	^ name
]

{ #category : 'accessing' }
PbOwner >> name: anObject [
	name := anObject
]
